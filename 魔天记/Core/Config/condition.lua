local condition={
[1]={1,1,'剩余血量'},
[2]={2,1,'通关时间'},
[3]={3,1,'击败指定boss'},
[4]={4,1,'守护目标'},
[5]={5,1,'胜利通关'},
[6]={6,1,'击杀怪物总数'},
[7]={7,2,'击杀指定boss,副本结束'},
[8]={8,2,'护送NPC达到目标地点，副本结束'},
[9]={9,2,'累计击杀小鬼达到指定数量，副本结束'},
[10]={10,2,'副本坚持存活一定时间，副本结束'},
[11]={11,2,'副本内有单位死亡，副本结束'},
[12]={12,2,'击杀副本所有怪物，副本结束'},
[17]={17,1,'剩余血量'}
}
local ks={id=1,type=2,name=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(condition)do setmetatable(v,base)end base.__metatable=false
return condition
