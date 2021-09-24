local MainViewMediator = classGc( mediator, function( self, _view )
	self.name = "MainViewMediator"
	self.view = _view
    self:regSelf()
end)

function MainViewMediator.setActivityView(self,_view)
    self.m_activityView=_view
end
function MainViewMediator.setSystemView(self,_view)
    self.m_systemView=_view
end

MainViewMediator.protocolsList={
    -- _G.Msg["ACK_TEAM_LIVE_REP"],-- [3730]查询队伍返回 -- 组队系统 
    _G.Msg["ACK_SIGN_POP_DATA"],-- [40022]登陆签到过的物品 -- 签到抽奖 

    _G.Msg["ACK_ROLE_OK_ASK_BUYE"],-- (手动) -- [1264]请求购买面板成功 -- 角色

    _G.Msg["ACK_SCENE_LEVEL_UP"], -- [5940]场景广播-升级 -- 场景 
    
    _G.Msg["ACK_LV_REWARD_LV_STATE"],--等级奖励

    _G.Msg["ACK_SYSTEM_ERROR"], --700

    _G.Msg["ACK_ROLE_ENERGY_OK"],  --刷新购买包子次数

    _G.Msg["ACK_ART_HOLIDAY"],-- [16725]精彩活动节日奖励翻倍 -- 包子
}

MainViewMediator.commandsList={
    CMainUiCommand.TYPE,
    CTaskEffectsCommand.TYPE,

    -- CGotoSceneCommand.TYPE,
    CFunctionUpdateCommand.TYPE,
    CActivityIconCommand.TYPE,
    CFunctionOpenCommand.TYPE,
    CFunctionSignCommand.TYPE,
    CTaskDialogUpdateCommand.TYPE,
    CTaskMainCommand.TYPE,

    CPropertyCommand.TYPE,
    CGuideNoticAdd.TYPE,
    CGuideNoticDel.TYPE,
    CGuideNoticShow.TYPE,
    CGuideNoticHide.TYPE
}

function MainViewMediator.processCommand( self, _command )
    local commandType = _command :getType()
    local commamdData = _command :getData()

    if commandType == CMainUiCommand.TYPE then
        if commamdData == CMainUiCommand.ICON_ADD then
            self.view :addIconBtnByType(_command.iconType)
        elseif commamdData == CMainUiCommand.ICON_DEL then
            self.view :removeIconBtnByType(_command.iconType)
        elseif commamdData == CMainUiCommand.SUBVIEW_ADD then
            --添加了子界面
            self.view :showNextSubView()
        elseif commamdData == CMainUiCommand.SUBVIEW_FINISH then
            --子界面已去除
            self.view :subViewFinish()
            print("MainViewMediator.processCommand111=",_command :getData(),debug.traceback())
        elseif commamdData == CMainUiCommand.MOPTYPE then
            self.m_activityView:showMopTypeIcon(_command.mopType)
        end
    elseif commandType == CTaskEffectsCommand.TYPE then
       if commamdData == _G.Const.CONST_TASK_STATE_UNFINISHED then
            self.view:showAcceptTaskEffect()
       elseif commamdData == _G.Const.CONST_TASK_STATE_SUBMIT then
            self.view:showFinishTaskEffect()
       end
    elseif commandType == CFunctionUpdateCommand.TYPE then
        if commamdData == CFunctionUpdateCommand.BUFF_TYPE then
            CCLOG("接收buff通知===========>>")
            self.m_activityView:setRoleBuffIcon()
        end
    -- elseif commandType == CGotoSceneCommand.TYPE then
        -- self.m_activityView:destory()
        -- self.m_systemView:destory()
    elseif commandType == CActivityIconCommand.TYPE then
        if commamdData == CActivityIconCommand.REMOVE_OTHER then
            --删除左边按钮
            if _command:getOtheData()~=nil then 
                print("CActivityIconCommand.REMOVE_OTHER--openId->",_command:getOtheData())
                self.m_activityView:removLeftButton( _command:getOtheData() )
            end 
        elseif commamdData == CActivityIconCommand.REMOVE_LAYOUT then
            --删除layout里面的按钮
            if _command:getOtheData()~=nil then 
                print("CActivityIconCommand.REMOVE_LAYOUT--openId->",_command:getOtheData())
                
            end
        elseif commamdData == CActivityIconCommand.EFFECT_REMOVE then
            --不管什么类型的特效  都清除
            if _command:getOtheData()~=nil then 
                print("CActivityIconCommand.EFFECT_REMOVE--openId->",_command:getOtheData())
                self.m_activityView:removeEffectsById(_command:getOtheData())
            end
        elseif commamdData == CActivityIconCommand.HIDE_TASK_GUIDE then
            self.m_activityView:hideTaskGuideEffect()
        end
    elseif commandType == CFunctionOpenCommand.TYPE then
        if commamdData == CFunctionOpenCommand.UPDATE then
            local chuangeIdList=_command.chuangeIdList
            self.m_activityView:sysOpenDataChuange(chuangeIdList)
            self.m_systemView:sysOpenDataChuange(chuangeIdList)
        elseif commamdData == CFunctionOpenCommand.TIMES_UPDATE then
            local sysId  = _command.sysId
            local number = _command.number
            self.m_activityView:resetSysNumber( sysId, number )
            self.m_systemView:resetSysNumber( sysId, number )
        elseif commamdData == CFunctionOpenCommand.LIMIT_ADD then
            local sysId = _command.sysId
            self.m_activityView:addOneLimitBtn(sysId)
        elseif commamdData == CFunctionOpenCommand.LIMIT_REMOVE then
            local sysId = _command.sysId
            self.m_activityView:removeUpButton(sysId)
            self.m_activityView:removLeftButton(sysId)
        elseif commamdData == CFunctionOpenCommand.SHOW_EFFECT then
            self.view:addSysOpenEffectData(_command.sysId)
        end
    elseif commandType == CFunctionSignCommand.TYPE then
        if commamdData == CFunctionSignCommand.SIGN_ADD then
            self.m_systemView:addSignSpr(_command.sysId)
        elseif commamdData ==CFunctionSignCommand.SIGN_DEL then
            self.m_systemView:delSignSpr(_command.sysId)
        end
    elseif commandType == CTaskDialogUpdateCommand.TYPE then
        if commamdData == CTaskDialogUpdateCommand.GOTO_TASK then
            print("+++++++++++!#!#!#!#!#!#---》CTaskDialogUpdateCommand.GOTO_TASK")
            self.m_activityView:onGuiderTask()
        end
    elseif commandType == CTaskMainCommand.TYPE then--指引任务更新
        self.m_activityView:updateTaskInfo()
    elseif commandType == CPropertyCommand.TYPE then
        if  commamdData == CPropertyCommand.VIP then
            --vip等级改变
            local vipLv = _command.vipLv
            self.view:updateVIP(vipLv)
        elseif  commamdData == CPropertyCommand.MONEY then
            self.view:updateMoney()
        elseif commamdData == CPropertyCommand.ENERGY then
            --体力更新
            print("当前体力值", _command.sum, _command.max)
            local _data = {}
            _data.sum = _command.sum
            _data.max = _command.max
            self.view:updateEnergy(_data)
        elseif commamdData == CPropertyCommand.POWERFUL_ALL then
            self.view:updatePowerNum()
        elseif commamdData == CPropertyCommand.EXP then
            self.view:updateExp()
        elseif commamdData == CPropertyCommand.LEVELUP then
            local roleLv = _command.lv
            self:roleLevelUp( roleLv )
        elseif commamdData == CPropertyCommand.NAME then
            self.view:updateName(command.name)
        end
    elseif commandType == CGuideNoticAdd.TYPE then
        self.view:addSysGuideNotic(_command.sysId)
    elseif commandType == CGuideNoticDel.TYPE then
        self.view:delSysGuideNotic(_command.sysId)
    elseif commandType == CGuideNoticShow.TYPE then
        self.view:setVisibleSysGuideNotic(true,true)
    elseif commandType == CGuideNoticHide.TYPE then
        self.view:setVisibleSysGuideNotic(false)
    end
end

function MainViewMediator.ACK_ART_HOLIDAY( self,_ackMsg)
    self.view:isDouble(_ackMsg.value)
end

function MainViewMediator.roleLevelUp( self, _roleLv )
    print("升级广播->", _roleLv)
    -- if not _G.pCDailyTaskProxy and _roleLv >= _G.Const.CONST_TASK_DAILY_ENTER_LV then
        -- 初始化日常任务信息
    --     self.view :initDailyTask()
    -- end

    -- if _roleLv>=_G.Const.CONST_MATIAX_OPEN then
    --     --阵法初始化数据
    --     local mainProperty=_G.GPropertyProxy:getMainPlay()
    --     if mainProperty:getMatrixData() == nil then
    --         CCLOG("请求阵法数据")
    --         local msg_matirx = REQ_MATRIX_REQUEST()
    --         msg_matirx:setArgs(0)
    --         _G.Network:send(msg_matirx)
    --     end
    -- end

    --检查新技能
    -- self:checkNewSkillStart(_roleLv)

    --播放升级特效
    self.view:roleLevelUp(_roleLv)
    self.m_activityView:checkOpenInfoUpdate(_roleLv)
end

-- [3730]查询队伍返回 -- 组队系统 
-- function MainViewMediator.ACK_TEAM_LIVE_REP(self,ackMsg)
--     local rep       = ackMsg.rep --队伍是否存在 0:不存在|1:存在
--     local types     = ackMsg.type
--     print("MainViewMediator.ACK_TEAM_LIVE_REP 队伍是否存在",rep,types)
--     if types == 1 or types == 2 then 
--         self.view: NetWorkReturn_TEAM_LIVE_REP(rep,types) --sever methond
--     end
-- end


-- [40022]登陆签到过的物品 -- 签到抽奖  CLotteryView ():layer()
function MainViewMediator.ACK_SIGN_POP_DATA( self, _ackMsg )
    CCLOG("40062 ACK_SIGN_POP_DATA ---> 弹窗类型 %d",_ackMsg.pop)

    local limitLv = _G.GPropertyProxy:getMainPlay():getLv()
    if limitLv < 2 then
        self.view:waitToOpenSignLayer(_ackMsg.pop)
        return
    end

    self.view :openSignLayer(_ackMsg.pop)

    CCLOG("40062 ACK_SIGN_POP_DATA ---> fuck")
    
end

function MainViewMediator.ACK_LV_REWARD_LV_STATE( self, _ackMsg )
    CCLOG("50401 ACK_LV_REWARD_LV_STATE --->%d,%d,%d",_ackMsg.lv,_ackMsg.state,_ackMsg.autoo)
    self.m_activityView:updateRewardButton(_ackMsg.lv,_ackMsg.state,_ackMsg.autoo)
end

function MainViewMediator.ACK_ROLE_ENERGY_OK( self )
    self.view:updateEnergyNum()
end

function MainViewMediator.checkNewSkillStart( self, _nowLv )
    local rolePro = _G.GPropertyProxy :getMainPlay() :getPro()
    local skillInitCnf = _G.Cfg.player_init[rolePro]
    local learnList = skillInitCnf.skill_learn or {}
    for i=3,#learnList do
        local skill_id = learnList[i]
        local skillCnf = _G.Cfg.skill[skill_id]
        if skillCnf.lv_min == _nowLv then
            local view = self.view
            self.view :addSubView(view.type_newSkill,skillCnf)
            return
        end
    end
end

function MainViewMediator.ACK_ROLE_OK_ASK_BUYE( self,_ackMsg)
    -- for k,v in pairs(_ackMsg) do
    --     print("EEEE===>",k,v)
    -- end
    -- local nType=_ackMsg.type
    -- if nType == _G.Const.CONST_ENERGY_REQUEST_TYPE then
        self.view:msgCallByEnergy(_ackMsg)
    -- elseif nType == _G.Const.CONST_ENERGY_RETRUN_TYPE then
    --     local function nFun()
    --         _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
    --     end
    --     _G.Util:showTipsBox(_G.Lang.ERROR_N[146],nFun)
    -- end
end

function MainViewMediator.ACK_SCENE_LEVEL_UP(self,_ackMsg)
    self.view:ortherPlayerLevelUp(_ackMsg)
end

function MainViewMediator.ACK_SYSTEM_ERROR(self, _ackMsg)
    print( "-- ACK_SYSTEM_ERROR",_ackMsg.error_code)
    if  _ackMsg.error_code == 134 then
    	self.view:xianyuReturn()
    elseif _ackMsg.error_code == 132 or
    	   _ackMsg.error_code == 131 then
    	self.view:tongqianReturn()
    elseif _ackMsg.error_code == 39560  then
    	self.view:goodsReturn(0)
    elseif _ackMsg.error_code == 38550 then
    	self.view:goodsReturn(1)
    elseif _ackMsg.error_code == 8020 then
    	self.view:goodsReturn(2)	
    elseif _ackMsg.error_code == 12040 then
    	self.view:reputationReturn()
    elseif _ackMsg.error_code == 7960 then
    	self.view:xuanjinReturn()
    elseif _ackMsg.error_code == 8203 then
    	self.view:gongdeReturn()
    elseif _ackMsg.error_code == 8050 then
    	self.view:openReturn(1)
    elseif _ackMsg.error_code == 39550 then
    	self.view:openReturn(2)
    elseif _ackMsg.error_code == 39555 then
        self.view:openReturn(6)
    elseif _ackMsg.error_code == 8060 then
    	self.view:openReturn(3)
    elseif _ackMsg.error_code == 40115 then
        self.view:openReturn(4)
    elseif _ackMsg.error_code == 40125 then
        self.view:openReturn(4)
    elseif _ackMsg.error_code == 40135 then
        self.view:openReturn(5)
    elseif _ackMsg.error_code == 290 then
    	self.view:artifactReturn()
    elseif _ackMsg.error_code == 123 then
    	self.view:starReturn()
    end
end


return MainViewMediator