-- --------------------------------------------------------------------
-- 自由移动场景的NPC
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleSceneNpc = RoleSceneNpc or BaseClass(RoleSceneObj)

function RoleSceneNpc:__init()
	self.model_scale = 0.8
end

function RoleSceneNpc:setVo(value)
    if value == nil then return end
    RoleSceneObj.setVo(self, value)
    if self.vo.sub_type == RoleSceneVo.sub_unittype.npc then
	    self:setModelScale(self.model_scale)
    end

	self:initSpine()
	if RolesceneController:getInstance():getIsInChiefWar() then
		if self.vo and self.vo.unit_type == 201 then 
			self:showEffectCircle()
		end
	end
	
	self:registEvent()
	
	if self.vo ~= nil then
		-- 设置状态的统一弄到initSpine里面设置
		if self.unit_attr_change == nil then
			self.unit_attr_change = self.vo:Bind(RolesceneEvent.UPDATE_ROLE_ATTRIBUTE, function( key, value )
				if key == "status" then 
					local bool = (value ==1) or false
					self:showBattleEffect(bool)
				end
			end)
		end
	end
end

function RoleSceneNpc:registEvent()
	self.main_container:setTouchEnabled(true)
	self.main_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			self:clickHandler()
		end
	end)
end

function RoleSceneNpc:update(dt)
    RoleSceneObj.update(self, dt)
	self:updateNamePos()
end

function RoleSceneNpc:clickHandler()
	GlobalEvent:getInstance():Fire(SceneEvent.SCENE_UNIT_CLICK, self.vo)
end
--创建自身角色箭头
function RoleSceneNpc:showEffectCircle()
	if not self.effect_circle then 
		local effect_id = Config.EffectData.data_effect_info[280] or ""
        self.effect_circle = createEffectSpine( effect_id, cc.p(89,0), cc.p(0.5, 0.5), true,"action")
        self.effect_container:addChild(self.effect_circle,-1)
	end
end
--==============================--
--desc:设置红点显示状态
--time:2017-10-17 10:45:06
--@status:
--@return 
--==============================--
function RoleSceneNpc:showRedPoint(status)
	if self.name_container == nil or tolua.isnull(self.name_container) then return end

	if status == false then
		if self.red then
			self.red:setVisible(false)
		end
	else
		if self.red == nil then
			self.red = createSprite(PathTool.getResFrame("common2","common_tishi"),self.name_container:getContentSize().width-3,self.name_container:getContentSize().height-8,self.name_container,cc.p(0.5,0.5))
		end
		self.red:setVisible(true)
	end
end

function RoleSceneNpc:__delete()
    if self.vo ~= nil then
		if self.unit_attr_change ~= nil then
			self.vo:UnBind(self.unit_attr_change)
			self.unit_attr_change = nil
		end
	end
end