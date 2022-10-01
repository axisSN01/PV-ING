% initialize PSAT
initpsat
% do not reload data file
clpsat.readfile = 0;
% set data file
runpsat('d_006_mdl','data')
% solve base case power flow
runpsat('pf')
voltages = DAE.y(1+Bus.n:2*Bus.n);
% increase base loading by 50%
for i = 1:2
PQ.store
PV.store
PQ.store(:,[4,5]) = (1+i/20)*[0.9, 0.6; 1, 0.7; 0.9, 0.6];
PV.store(:,4) = (1+i/20)*[0.9; 0.6];
runpsat('pf')
voltages = [voltages, DAE.y(1+Bus.n:2*Bus.n)];
end