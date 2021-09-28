local MoShenPageViewItem = class("MoShenPageViewItem",function ()
    return CCSPageCellBase:create("ui_layout/moshen_MoShenPageViewItem.json")
end)
require("app.cfg.rebel_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local KnightPic = require("app.scenes.common.KnightPic")
function MoShenPageViewItem:ctor(...)
	self._bossList = {}
	self._bossEffectList = {}
	self:getLabelByName("Label_name01"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_name02"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_name03"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_status01"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_status02"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_status03"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_finder01"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_finder02"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_finder03"):createStroke(Colors.strokeBrown,1)
end

function MoShenPageViewItem:update(rebelList)
	if rebelList == nil or type(rebelList) ~= "table" then
		return
	end

	for i=1,3 do
		if rebelList[i] ~= nil then
			local rebel = rebel_info.get(rebelList[i].id)
			local panel = self:getPanelByName("Panel_knight0" .. i)
			local nameLabel = self:getLabelByName("Label_name0" .. i)
			local finderLabel = self:getLabelByName("Label_finder0" .. i)
			local statusLabel = self:getLabelByName("Label_status0" .. i)
			nameLabel:setColor(Colors.qualityColors[rebel.quality])
			local bloodLoadingBar = self:getLoadingBarByName("ProgressBar_blood0" .. i)
			bloodLoadingBar:setPercent(self:getRebelBloodPercent(rebelList[i]))

			if rebel == nil then
				self:showWidgetByName("Panel_0" .. i,false)
			else
				self:showWidgetByName("Panel_0" .. i,true)
				nameLabel:setText(rebel.name)
				-- finderLabel:setText("发现者:" .. rebelList[i].name)
				local finderIsMe = rebelList[i].user_id == G_Me.userData.id
				finderLabel:setText(G_lang:get("LANG_MOSHEN_FINDER",{name=rebelList[i].name}))
				finderLabel:setColor(finderIsMe and Colors.darkColors.TIPS_01 or Colors.darkColors.DESCRIPTION)
				-- self._bossList[i] = KnightPic.createKnightButton(rebel.res_id,panel,rebelList[i].user_id,self,function()
					--以time为key
				if rebelList[i].status == 0 and (finderIsMe and true or rebelList[i].public) then
					local name = G_ServerTime:getTime() .. rebelList[i].user_id
					if self._bossList[i] and self._bossList[i].loadTexture then
						self._bossList[i]:removeFromParentAndCleanup(true)
						self._bossList[i] = nil
					end
					if self._bossList[i] == nil then
						self._bossList[i] = KnightPic.createKnightButton(rebel.res_id,panel,name,self,function()
								--进入魔神信息界面
								require("app.scenes.moshen.MoShenInfoDialog").show(rebelList[i])
								end,true)
						if self._bossEffectList[i] == nil then
							self._bossEffectList[i] = EffectSingleMoving.run(panel, "smoving_idle", nil, {},math.random(1,50)*30)
						end
					else
						if self._bossList[i] and self._bossList[i].loadTextureNormal then
							self._bossList[i]:loadTextureNormal(G_Path.getKnightPic(rebel.res_id))
						end
					end
					--重新注册下事件,否则会有问题
					self:registerBtnClickEvent(self._bossList[i]:getName(),function()
						require("app.scenes.moshen.MoShenInfoDialog").show(rebelList[i])
						end)
				else 
					if self._bossEffectList[i] ~= nil then
					    self._bossEffectList[i]:stop()
					    self._bossEffectList[i] = nil
					end
					if self._bossList[i] ~= nil then
						self._bossList[i]:removeFromParentAndCleanup(true)
						self._bossList[i] = nil
					end
					self._bossList[i] = KnightPic.createKnightPic(rebel.res_id,panel,nil,true)
					self._bossList[i]:showAsGray(true);
				end
				self._bossList[i]:setScale(0.6)

				--判断是否已被击杀
				if rebelList[i].hp <= 0 then
					if self._bossEffectList[i] ~= nil then
					    self._bossEffectList[i]:stop()
					    self._bossEffectList[i] = nil
					end
					rebelList[i].status = 1
					statusLabel:setVisible(true)
					statusLabel:setText(G_lang:get("LANG_MOSHEN_BOSS_STATUS_KILLED"))
					-- self._bossList[i]:showAsGray(true);
				else
					--判断是否已逃走
					local endTime = rebelList[i]["end"]
					endTime = G_ServerTime:getLeftSeconds(endTime)
					if endTime < 0 then
						if self._bossEffectList[i] ~= nil then
						    self._bossEffectList[i]:stop()
						    self._bossEffectList[i] = nil
						end
						rebelList[i].status = 2
						statusLabel:setVisible(true)
						statusLabel:setText(G_lang:get("LANG_MOSHEN_BOSS_STATUS_ESCAPE"))
						-- self._bossList[i]:showAsGray(true);
					else
						statusLabel:setVisible(false)
						-- self._bossList[i]:showAsGray(false);
					end
				end
				

			end
		else
			self:showWidgetByName("Panel_0" .. i,false)
		end
	end
end

function MoShenPageViewItem:getRebelBloodPercent(rebel)
    if rebel == nil then 
        return 0
    end
    local result =  rebel.hp/rebel.max_hp*100 
    return result-result%1
end


return MoShenPageViewItem
