--Effect.lua
--效果基类

Effect = class()

local prop = Property(Effect)

prop:accessor("datas")	--传过来的数据

function Effect:__init(config)
	prop(self, "datas", config)
end

function Effect:doTest()
	
end

function Effect:doEffect()

end

--批量使用
function Effect:doBatchTest()

end

function Effect:doBatchEffect()

end

function Effect:doFireMessage()

end