-- @author hze
-- @date #2019/06/03#
--幸运树-摇一下活动vo
local _pairs = pairs
LuckyTreeDataVo = LuckyTreeDataVo or {}

function LuckyTreeDataVo.Create()
    local dat = {}
    dat.id = id      	  	  	  -- "编号"
    dat.site = 0		  		  -- "位置"
	dat.item_id = 0               -- "道具id"
	dat.item_num = 0  			  -- "道具数量"
	dat.effect = 0  			  -- "是否特效"
	dat.flag = 1	  	  		  -- "1:未领取, 2：已领取"
	

	dat.icon = 0
	dat.isEffect = false
	dat.isFlag = false
	
	LuckyTreeDataVo.Init(dat)
    return dat
end

function LuckyTreeDataVo.Init(vo)
    BaseUtils.covertab(vo, LuckyTreeDataVo)
end

function LuckyTreeDataVo:SetData(data)
	for k,v in pairs(data) do
		self[k] = v
	end
	self.isEffect = self.effect == 1 
	self.isFlag = self.flag == 2 
	self.icon = DataItem.data_get[self.item_id].icon
end



