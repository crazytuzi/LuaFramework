local p = require "protocoldef.knight.gsp.activity.common.sactbuttoninfo"
function p:process()
	LogInfo("protocoldef.knight.gsp.activity.common.sactbuttoninfo process start")
	
	-- 华山之巅

	if self.actid == 149 then
		require "ui.crossserver.huashanzhidianbtn"
		if self.status == 1 then
			LogInfo("client receive the message:  " .. self.status)
			if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
				HuashanzhidianBtn.getInstance():SetVisible(false)
			else
				HuashanzhidianBtn.getInstanceAndShow()
			end
		else
			LogInfo("stop activity stutus:  " .. self.status)
			HuashanzhidianBtn.DestroyDialog()
		end	

		return
	end
	
	-- 一站到底

	if self.actid == 144 then
		local YiZhanDaoDiBtn = require "ui.yizhandaodi.yizhandaodibtn"
		if self.status == 1 then
			if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
				YiZhanDaoDiBtn.getInstance():SetVisible(false)
			else
				YiZhanDaoDiBtn.getInstanceAndShow()
			end
		else
			YiZhanDaoDiBtn.DestroyDialog()
		end	

		return
	end

	-- 降服珍兽

	if self.actid == 146 then
		local XiangFuZhenShouBtn = require "ui.xiangfuzhenshoubtn"
		if self.status == 1 then
			if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
				XiangFuZhenShouBtn.getInstance():SetVisible(false)
			else
				XiangFuZhenShouBtn.getInstanceAndShow()
			end
		else
			XiangFuZhenShouBtn.DestroyDialog()
		end	

		return
	end

	-- 兵临城下

	if self.actid == 148 then
		local BingLinChengXia = require "ui.binglinchengxia.binglinchengxiabtn"
		if self.status == 1 then
			if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
				BingLinChengXia.getInstance():SetVisible(false)
			else
				BingLinChengXia.getInstanceAndShow()
			end
		else
			BingLinChengXia.DestroyDialog()
		end	

		return
	end

	-- 行侠仗义

	if self.actid == 161 then
		local XingXiaZhangYiBtn = require "ui.xingxiazhangyibtn"
		if self.status == 1 then
			if GetScene():IsInFuben() or GetBattleManager():IsInBattle() then
				XingXiaZhangYiBtn.getInstance():SetVisible(false)
			else
				XingXiaZhangYiBtn.getInstanceAndShow()
			end
		else
			XingXiaZhangYiBtn.DestroyDialog()
		end	

		return
	end

	LogInfo("protocoldef.knight.gsp.activity.common.scountdown process end")
end
