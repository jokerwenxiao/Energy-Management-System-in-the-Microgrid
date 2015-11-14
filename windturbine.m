function p = windturbine(v,status,prated)
    % wind.m 
    % v=[10,11,12,12,12,12,12,13,15,16,17,17,18,19,19,20,21,22,23,24,25,26,27,28];

    von = 3;        % cut-on speed (m/s)
    vc = 14;        % corner speed (m/s)
    vout = 25;      % cut-out speed (m/s)
    diameter = 10;
    rho = 0.1;
    capacity_factor=0.2;
    %p = zeros( size(v) );
    
    if(status==1)
        swept_area = pi * (diameter/2)^2;
        % Below cut-on
        p(v < von) = 0;
        % Ramp up (use model)
        I = (v >= von & v < vc);
        p(I) = 0.5 * swept_area * (v(I).^3) * rho * capacity_factor;    % P = 1/2 * v^3 * A * p *Cp
        % At rated power
        p(v >= vc & v <= vout) = prated;
        % Above cut-out
        p(v > vout) = 0;

%         figure(1);%Plot the I-V characteristic curve
%         axis([0,30,0,800])
%         plot(v,p);
%         grid;
    end
end