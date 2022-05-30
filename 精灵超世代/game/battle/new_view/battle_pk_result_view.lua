-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:战斗结算主界面]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

BattlePkResultView = BattlePkResultView or BaseClass(BaseView)


function BattlePkResultView:__init(result,fight_type)
	self.result = result
	self.x = 100
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.is_running = true
	self.partner_list = {}
	self.item_list = {}
	self.is_stop = false
	self.is_open_box = false
	self.win_type = WinType.Tips
	self.fight_type = fight_type
	self.layout_name = "battle/battle_pk_result_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.effect_list = {}
	self.is_full_screen = false
	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}
	self.star = 0
end

function BattlePkResultView:openRootWnd(data)
	self:setData(data)
	self.fight_type = data.combat_type
end

--初始化
function BattlePkResultView:open_callback()
	local res = ""
	playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE)

	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	self.source_container = self.root_wnd:getChildByName("container")
	--self.source_container:setScale(display.getMaxScale())
	self.title_container = self.source_container:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height
	self.world_btn = self.source_container:getChildByName("world_btn")
	self.world_btn:getChildByName("label"):setString(TI18N("世界分享"))
	-- self.world_btn:setTitleText(TI18N("世界分享"))
	-- self.world_btn.label = self.world_btn:getTitleRenderer()
	-- if self.world_btn.label ~= nil then
	-- 	self.world_btn.label:enableOutline(cc.c3b(108, 43, 0), 2)
	-- end
	self.guild_btn = self.source_container:getChildByName("guild_btn")
	self.guild_btn:getChildByName("label"):setString(TI18N("公会分享"))
	-- self.guild_btn:setTitleText(TI18N("公会分享"))
	-- self.guild_btn.label = self.guild_btn:getTitleRenderer()
	-- if self.guild_btn.label ~= nil then
	-- 	self.guild_btn.label:enableOutline(cc.c3b(108, 43, 0), 2)
	-- end
	self.record_btn = self.source_container:getChildByName("record_btn")
	self.record_btn:getChildByName("label"):setString(TI18N("回放"))
	-- self.record_btn:setTitleText(TI18N("回放"))
	-- self.record_btn.label = self.record_btn:getTitleRenderer()
	-- if self.record_btn.label ~= nil then
	-- 	self.record_btn.label:enableOutline(cc.c3b(108, 43, 0), 2)
	-- end

	self.harm_btn = self.source_container:getChildByName("harm_btn")
	self.harm_btn:setVisible(false)
	self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))
end


function BattlePkResultView:register_event()
	if self.background then
		self.background:addTouchEventListener(function(sender, event_type) --人物层
			if event_type == ccui.TouchEventType.ended then
				BattleController:getInstance():openFinishView(false,self.fight_type)
			end
		end)
	end
	if self.world_btn then
		self.world_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
					if self._is_cross then
						BattleController:getInstance():on20034(self.data.replay_id, ChatConst.Channel.Cross, self.data.def_name,BattleConst.ShareType.SharePk)
					else
						BattleController:getInstance():on20034(self.data.replay_id, ChatConst.Channel.World, self.data.def_name,BattleConst.ShareType.SharePk)
					end
				end
				BattleController:getInstance():openFinishView(false,self.fight_type)
			end
		end)
	end
	if self.guild_btn then
		self.guild_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
			local role_vo = RoleController:getInstance():getRoleVo()
			if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= "" then
				BattleController:getInstance():on20034(self.data.replay_id, ChatConst.Channel.Gang, self.data.def_name,BattleConst.ShareType.SharePk)
			else
				message(TI18N("暂无公会"))
			end
			end
		end)
	end
	if self.record_btn then
		self.record_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				BattleController:getInstance():openFinishView(false, self.fight_type)
				if self.data then
					BattleController:getInstance():csRecordBattle(self.data.replay_id)
				end
			end
		end)
	end
	if self.harm_btn then
		registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
	end
end

function BattlePkResultView:_onClickHarmBtn(  )
	if self.data and next(self.data) ~= nil then
		local setting = {}
        setting.fight_type = self.fight_type
		BattleController:getInstance():openBattleHarmInfoView(true, self.data, setting)
	end
end

--剧情：{章节id,难度，副本id}
function BattlePkResultView:setData(data)
	if data then
		self.data = data or {}
        self:handleEffect(true)
        self.harm_btn:setVisible(true)

        self._is_cross = false
        if data.is_province and data.is_province == 1 then
        	self._is_cross = true
        	-- self.world_btn:setTitleText(TI18N("跨服分享"))        	
			self.world_btn:getChildByName("label"):setString(TI18N("跨服分享"))
        end
	end
end

function BattlePkResultView:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
            if self.data.result == 1 then 
                self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
            else
                self.play_effect = createEffectSpine(PathTool.getEffectRes(104), cc.p(self.title_width * 0.5, self.title_height * 0.5 + 40), cc.p(0.5, 0.5), false, PlayerAction.action)
            end
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

--清理
function BattlePkResultView:close_callback()
	self:handleEffect(false)
	if BattleController:getInstance():getModel():getBattleScene() and BattleController:getInstance():getIsSameBattleType(self.fight_type) then
		local data = { combat_type = self.fight_type, result = self.result }
		BattleController:getInstance():getModel():result(data,self.is_leave_self)
	end
end
