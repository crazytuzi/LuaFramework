

--策划只要吧gm 指令用双引号括起来放到下面的表里面就ok了， 别忘了逗号。
GM = 
{ 
"for i=0,3 do player:addmoney(i, 99999999) end",
"for i=1,5 do player:addmagicexp(i, 500) end",
"for i=1,5 do player:addcardexp(i,9999) end",
"player:setplayerlevel(30)",
"player:setrmb(20000)",
"for j=259, 264 do player:additem(0, j, 6) end",
}

GM.call = function()
	for i,v in ipairs (GM) do
		sendGm(v)
	end
end

GM.call()




----------------------修改后 无需重启客户端







 -------------这里给程序测试--------------------
GM__Test =
{
	"for i=0,3 do player:addmoney(i, 2000) end",
}
GM__Test.call = function()
	for i,v in ipairs (GM__Test) do
		sendGm(v)
	end
end
GM__Test.call()

 -------------这里给程序测试--------------------
