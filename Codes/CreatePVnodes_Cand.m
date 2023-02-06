function [PvNodecand] = CreatePVnodes_Cand()

for jj=1:10
    for ii=1:10
        PvNodecand(jj,ii)=round(rand*85)+5;   %since there are 85 PV injectable nodes generating limit is 5-90
    end
end

end