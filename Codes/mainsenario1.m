clear
close all
[DSSStartOK, DSSObj, DSSText] = DSSStartup;
if DSSStartOK

    DSSCircuit=DSSObj.ActiveCircuit;
    DSSSolution=DSSCircuit.Solution;
    DSSText.command='Compile (C:\Users\Ömer Ulu\Desktop\Hosting_Cap_Project\Codes\IEEE123Master.dss)';
    DSSText.Command='set mode=daily stepsize=1h ';          %Setting the solution mode as daily with a stepsize of 1 hour

    DSSText.Command='RegControl.creg1a.maxtapchange=0  !Allow only one tap change per solution. This one moves first';  %since all the regulators deactive tapchange is 0
    DSSText.Command='RegControl.creg2a.maxtapchange=0  !Allow only one tap change per solution';
    DSSText.Command='RegControl.creg3a.maxtapchange=0  !Allow only one tap change per solution';
    DSSText.Command='RegControl.creg4a.maxtapchange=0  !Allow only one tap change per solution';
    DSSText.Command='RegControl.creg3c.maxtapchange=0  !Allow only one tap change per solution';
    DSSText.Command='RegControl.creg4b.maxtapchange=0  !Allow only one tap change per solution';
    DSSText.Command='RegControl.creg4c.maxtapchange=0  !Allow only one tap change per solution';


    [PvNodecand] = CreatePVnodes_Cand();        %Generating the PV node points randomly for 10 senario
    MyLoads = DSSCircuit.Loads;                 %Take the load information drom OpenDSS to be able to add negative load to the system
    c=1;aa=1;
    %% Add PVs to the randomly created nodes
    for senario=1:10
        MyPVPower=0;
        for kk=1:100
            DSSText.command='Compile (C:\Users\Ömer Ulu\Desktop\Hosting_Cap_Project\Codes\IEEE123Master.dss)';
            MyPVPower=MyPVPower+3;
            for jj=1:10         
                MyLoads.First;
                for ii=1:PvNodecand(senario,jj)-1
                    MyLoads.Next;
                end
                reactivepowertostore=MyLoads.kvar;      %Since there will be a change in Kvar due to the ratio keep it
                MyLoads.kvar=0;
                MyLoads.kw=MyLoads.kw-MyPVPower;           %Add the new PV power
                MyLoads.kvar=reactivepowertostore;         %Recall the reactive power
            end

            for ii=1:1:24
                DSSSolution.Solve;                      %solve the power flow
                V1 = DSSCircuit.AllNodeVmagPUByPhase(1);    %Take the V1 voltage magnitudes in V1 variable in PU
                phase1max(ii)=max(V1);                      %Keep the maximum number inside the V1 variable
                V2 = DSSCircuit.AllNodeVmagPUByPhase(2);    %Take the V1 voltage magnitudes in V1 variable in PU
                phase2max(ii)=max(V2);                      %Keep the maximum number inside the V1 variable
                V3 = DSSCircuit.AllNodeVmagPUByPhase(3);    %Take the V1 voltage magnitudes in V1 variable in PU
                phase3max(ii)=max(V3);                      %Keep the maximum number inside the V1 variable
                DSSCircuit.Solution.Hour = ii;              %Increase the hour value 
            end
            indayMaxV1(c)=max(phase1max);indayMaxV2(c)=max(phase2max);indayMaxV3(c)=max(phase3max); %Take the maximum voltage magnitude in that day

            if indayMaxV1(c)>1.05 | indayMaxV2(c)>1.05 | indayMaxV3(c)>1.05
                overflowsituations(aa,:)="There is an overflow when PV powers are "+MyPVPower+"kW at locations "+PvNodecand(senario,1)+" "+PvNodecand(senario,2)+" "+PvNodecand(senario,3)+" "+PvNodecand(senario,4)+" "+PvNodecand(senario,5)+" "+PvNodecand(senario,6)+" "+PvNodecand(senario,7)+" "+PvNodecand(senario,8)+" "+PvNodecand(senario,9)+" "+PvNodecand(senario,10)+" buses and with the phase magnitudes in PU V1= "+indayMaxV1(c)+" V2= "+indayMaxV2(c)+" V3= "+indayMaxV3(c) ;
                aa=aa+1;
            end
            c=c+1;


        end
    end

    plot(indayMaxV1,'r+');
    hold on
    plot(indayMaxV2,'g*');
    hold on
    plot(indayMaxV3,'b+');
    xlabel("The Day Number of The Simulation");
    ylabel("The Voltage Magnitudes of the Phases in PU ");
    legend("Phase 1","Phase 2","Phase 3",'Location','northwest','NumColumns',1);

end


