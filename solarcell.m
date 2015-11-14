function Ia = solarcell(Va,Suns,TaC)
    k = 1.38e-23; % Boltzmann constant
    q = 1.60e-19; % Electron
    n = 1.2; % Quality factor for the diode. n=1.2 for crystaline
    Vg = 1.12; %  [eV]
    T1 = 273 + 25; % Kelvin
    
    Voc_T1 = 0.665; % Open-current voltage at T1 [V]
    Isc_T1 = 5.75; % Short-circuit current at T1 [A]
    
    K0 = 3.5/1000; % Current/Temperature coefficient [A/K]
    
    dVdI_Voc = -0.00985; % dV/dI coefficient at Voc [A/V]
    
    TaK = 273 + TaC; % Convert cell's temperature from Celsius to Kelvin [K]
    
    IL_T1 = Isc_T1 * Suns; % Compute IL depending the suns at T1
    IL = IL_T1 + K0 * (TaK - T1); % Apply the temperature effect
    
    I0_T1 =  Isc_T1 / ( exp( q * Voc_T1 / ( n * k * T1 ) ) - 1 );
    I0 = I0_T1 * ( TaK / T1 ) .^ (3/n) .* exp( -q * Vg / ( n * k ) .* ( (1./TaK) - (1/T1) ) );
    
    Xv = I0_T1 * q / ( n * k * T1 ) * exp( q * Voc_T1 / ( n * k * T1 ) );
    Rs = - dVdI_Voc - 1/Xv; %Compute Rs Resistance
    
    Vt_Ta = n * k * TaK / q;
    Ia = zeros(size(Va)); %Initialize Ia vector
    
    % Compute Ia with Newton method
    for j=1:5;
        Ia = Ia - (IL - Ia - I0.*( exp( (Va + Ia .* Rs) ./ Vt_Ta ) - 1 ) ) ./ (-1 - ( I0.*( exp( (Va+Ia.*Rs) ./ Vt_Ta ) -1 ) ) .* Rs ./ Vt_Ta );
    end
end
