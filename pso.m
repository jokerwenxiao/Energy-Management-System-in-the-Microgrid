function [final_global_best,ind, gbest, val swarm, bestval, gb_mt, gb_batt, gb_util, soch] = pso(DV, putil, pload, ppv, pwt, soc, status, range_max_pbatt,chrpwr_min, range_max_mt,swarm_size)
%% Particle Swarm Optimization Simulation
%% Initialization
    % Parameters 
    iterations = 400;
    inertia = 1.0;
    correction_factor = 1.5;
    range_min_pbatt = 0;    
    range_min_mt = 0;
    ind = ones(1,iterations);
    gbest = zeros(1,iterations);
    bestval = zeros(iterations,swarm_size);
    swarm = zeros(swarm_size,size(DV,2),3);
    swarm(:, 1:size(DV,2), 1) = DV;   % Decision Variables
    swarm(:,:, 2, :) = 100;             % initial velocity
    val = zeros(iterations,swarm_size);
    gb_mt = zeros(1,size(DV,2)/2);
    gb_util = zeros(1,size(DV,2)/2);
    gb_batt = zeros(1,size(DV,2)/2);
	swarm(:, 1:size(DV,2)/2, 3) = swarm(:, 1:size(DV,2)/2, 1);                          % update best BATTERY positions
	swarm(:, size(DV,2)/2+1:size(DV,2), 3) = swarm(:, size(DV,2)/2+1:size(DV,2), 1);    % update best MICROTURBINE positions
    soc_best = zeros(iterations,size(DV,2)/2);
    
    for k=1:iterations
        for i=1:swarm_size
            bestval(k,i) = objFun(swarm(i, size(DV,2)/2+1 : size(DV,2), 1), putil(i,:),status);
        end
    end
    
    [ gbest(1), ind(1) ] = min( bestval(1,:) );
%% ITERATIONS
    for iter = 1 : iterations
        iter
%% FOR EACH POPULATION
        for i = 1 : swarm_size   
            infin = zeros(1,size(DV,2)/2);
%% 24-HOURS A DAY ESTIMATION
            for t = 1 : size(DV,2)/2
%% UPDATE VELOCITY AND POSITIONS
    step=0.2;

                %% pbatt 
                %velocity component
                swarm(i, t, 2) = (rand * step + step) * inertia * swarm(i, t, 2) + correction_factor * rand * ( swarm(i, t, 3) - swarm(i, t, 1) ) + correction_factor * rand * ( swarm(ind(iter), t,  3) - swarm(i, t, 1) );
                %update position
                swarm(i, t, 1) = swarm(i, t, 1) + swarm(i, t, 2);
                
                step_mul=0.2;
                while( ( ( swarm(i, t, 1) < chrpwr_min ) || ( swarm(i, t, 1) > range_min_pbatt ) ) && (soc(i,t)<=0.2))
                    swarm(i, t, 1) = swarm(i, t, 1) - swarm(i, t, 2);
                    swarm(i, t, 2) = (rand * step + step) * inertia * swarm(i, t, 2) + correction_factor * rand * ( swarm(i, t, 3) - swarm(i, t, 1) ) + correction_factor * rand * ( swarm(ind(iter), t,  3) - swarm(i, t, 1) );
                    swarm(i, t, 2) = step_mul*swarm(i, t, 2);
                    swarm(i, t, 1) = swarm(i, t, 1) + swarm(i, t, 2);
                    step_mul=step_mul+0.05;
                    if(swarm(i, t, 1)==inf || swarm(i, t, 1)==-inf || swarm(i, t, 2)==inf || swarm(i, t, 2)==-inf)
                        swarm(i, t, 1) = chrpwr_min + rand()*(soc(i,t)*range_min_pbatt-chrpwr_min);
                    end
                end
                
                step_mul=0.2;
                 while(( ( swarm(i, t, 1) < range_min_pbatt ) || ( swarm(i, t, 1) > (soc(i,t)*range_max_pbatt) ) ) && (soc(i,t)>0.2))
                    swarm(i, t, 1) = swarm(i, t, 1) - swarm(i, t, 2);
                    swarm(i, t, 2) = (rand * step + step) * inertia * swarm(i, t, 2) + correction_factor * rand * ( swarm(i, t, 3) - swarm(i, t, 1) ) + correction_factor * rand * ( swarm(ind(iter), t,  3) - swarm(i, t, 1) );
                    swarm(i, t, 2) = step_mul*swarm(i, t, 2);
                    swarm(i, t, 1) = swarm(i, t, 1) + swarm(i, t, 2);
                    step_mul=step_mul+0.05;
                    if(swarm(i, t, 1)==inf || swarm(i, t, 1)==-inf || swarm(i, t, 2)==inf || swarm(i, t, 2)==-inf)
                        swarm(i, t, 1) = range_min_pbatt + rand()*(soc(i,t)*range_max_pbatt-range_min_pbatt);
                    end
                end
                %% pmt 
                %velocity component
                swarm(i, size(DV,2)/2 + t, 2) = (rand * step + step) * inertia * swarm(i, size(DV,2)/2 + t, 2) + correction_factor * rand * ( swarm(i, size(DV,2)/2 + t, 3) - swarm(i, size(DV,2)/2 + t, 1) ) + correction_factor * rand * ( swarm(ind(iter), size(DV,2)/2 + t,  3) - swarm(i, size(DV,2)/2 + t, 1) );
                %update pmt position
                swarm(i, size(DV,2)/2 + t, 1) = swarm(i, size(DV,2)/2 + t, 1) + swarm(i, size(DV,2)/2 + t, 2);
%% CONSTRAINTS
                if( ( ( swarm(i, t, 1) < chrpwr_min ) || ( swarm(i, t, 1) >= range_min_pbatt ) ) && (soc(i,t)<=0.2)) || isnan(swarm(i, t, 1))==1
                    infin(t) = inf;
                    break;
                elseif(( ( swarm(i, t, 1) <= range_min_pbatt ) || ( swarm(i, t, 1) > (soc(i,t)*range_max_pbatt) ) ) && (soc(i,t)>0.2)) || isnan(swarm(i, t, 1))==1
                    infin(t) = inf;
                    break;
                else
                    ar = [range_max_pbatt/2 swarm(i, 1:t-1, 1)];
                    [soc(i,t) swarm(i, t, 1)] = battery(swarm(i, t, 1),ar,range_max_pbatt);
                end

                %microturbine power boundaries
                if( swarm(i, size(DV,2)/2 + t, 1) < range_min_mt ) || ( swarm(i, size(DV,2)/2 + t, 1) > range_max_mt )
                    infin(t) = inf;
                    break;
                else
                    [ swarm(i, size(DV,2)/2 + t, 1) ~ ] = microturbine(swarm(i, size(DV,2)/2 + t, 1),status(t),range_max_mt);
                end
            end
%% EVALUATION FUNCTION

            if any(infin==inf)
                val(iter,i) = inf;
            else
                val(iter,i) = objFun(swarm(i, size(DV,2)/2+1 : size(DV,2), 1), putil(i,:), status);   % fitness evaluation
            end
            
            if  ( val(iter,i) <  bestval(iter,i) ) &&  ( soc(i,size(DV,2)/2)>=0.5 )                      % if new position is better
                swarm(i, 1 : size(DV,2)/2, 3) = swarm(i, 1 : size(DV,2)/2, 1);                      % update best BATTERY positions  
                swarm(i, size(DV,2)/2+1 : size(DV,2), 3) = swarm(i, size(DV,2)/2+1 : size(DV,2), 1);% update best MICROTURBINE positions
                bestval(iter,i) = val(iter,i);                                                           % and best value
                soc_best(i,:) = soc(i,:);
            end
        end
%% ITERATION BEST (final iteration best is GLOBAL BEST too)
        [ gbest(iter), ind(iter) ] = min( bestval(iter,:) );
        
        if iter>1
            if gbest(iter-1)<gbest(iter)
                gbest(iter) = gbest(iter-1);
                ind(iter) = ind(iter-1);
            end
        end
                
        gb_mt = swarm(ind(iter), size(DV,2) / 2 + 1 : size(DV,2), 3);
        gb_batt = swarm(ind(iter), 1 : size(DV,2) / 2, 3);
        soch = soc_best(ind(iter),:);
        gb_util = pload - (ppv + pwt + gb_mt + gb_batt);
%         gb_util(gb_util<0) = 0; % uncomment to just not sell
%         gb_util(gb_util>=0) = 0; % uncomment the current and the above
%         line to not buy not sell
    end
    final_global_best = gbest(iter);
end