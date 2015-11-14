function plot_from_excel(name)
    Dat=xlsread(name);
    h=figure;
    set(gcf,'Visible','off');
    t=1:24;
    plot(t,Dat(1,1:24),t,Dat(2,1:24),t,Dat(3,1:24),t,Dat(4,1:24),t,Dat(5,1:24),t,Dat(6,1:24));
    xlabel('Time(Hour of day)')
    ylabel('Power Output (Watt)')                
    grid on;
    title('PSO')
    legend('MT','PV','WT','BTR','Load','Utility');
    baseFileName =  sprintf('%s.jpg', name);
    saveas(h, baseFileName ); 
end