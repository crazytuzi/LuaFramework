local grade={
[1]={1,'一品',1,29},
[2]={2,'二品',30,89},
[3]={3,'三品',90,149},
[4]={4,'四品',150,199},
[5]={5,'五品',200,249},
[6]={6,'六品',250,299},
[7]={7,'七品',300,349},
[8]={8,'八品',350,399},
[9]={9,'九品',400,449},
[10]={10,'十品',450,500}
}
local ks={key=1,name=2,min_level=3,max_level=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(grade)do setmetatable(v,base)end base.__metatable=false
return grade
