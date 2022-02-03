-- --------------------------------------------------------------------
-- 我要变强
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
StrongerController = StrongerController or BaseClass(BaseController)

function StrongerController:config()
    self.model = StrongerModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    
    self.is_first = true
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.stronger,self.is_first )
end

function StrongerController:setIsFirst( bool )
    self.is_first = bool
end

function StrongerController:getIsFirst( )
    return self.is_first
end

function StrongerController:getModel()
    return self.model
end

function StrongerController:registerEvents()

end

function StrongerController:registerProtocals()
    self:RegisterProtocal(11070, "on11070")   -- 全服最强数据
end

function StrongerController:sender11070( partner_bid )
    local protocal = {}
    protocal.partner_bid = partner_bid
    self:SendProtocal(11070, protocal)
end

function StrongerController:on11070( data )
    self.model:setDataByBid(data)
    self.dispather:Fire(StrongerEvent.UPDATE_SCROE,data)
end

--打开我要变强主界面
function StrongerController:openMainWin(status,index,partner_id)
	if status then 
        if not self.main_win  then
            self.main_win = StrongerMainWindow.New(partner_id)
        end
        self.main_win:open(index)
    else
        if self.main_win then 
            self.main_win:close()
            self.main_win = nil
        end
    end
end

-- 引导需要
function StrongerController:getStrongerRoot(  )
    if self.main_win then
        return self.main_win.root_wnd
    end
end

--跳转
function StrongerController:clickCallBack( evt_type )
    if evt_type then
        if evt_type == 200 then     -- 英雄背包
            JumpController:getInstance():jumpViewByEvtData({19})
        elseif evt_type == 201 then -- 神器升级
            JumpController:getInstance():jumpViewByEvtData({20})
        elseif evt_type == 202 then -- 联盟技能界面
            JumpController:getInstance():jumpViewByEvtData({32})
        elseif evt_type == 203 then -- 玩家英雄信息界面
            if self.main_win and self.main_win.view_list[1] then
                local cur_hero_item = self.main_win.view_list[1]:getCurHero()
                if cur_hero_item then
                    local hero_vo = cur_hero_item:getData()
                    local all_role_list = HeroController:getInstance():getModel():getAllHeroArray()
                    HeroController:getInstance():openHeroMainInfoWindow(true, hero_vo, all_role_list.items, {show_model_type = HeroConst.BagTab.eBagHero})
                end
            end
        elseif evt_type == 204 then -- 先知殿
            JumpController:getInstance():jumpViewByEvtData({24})
        elseif evt_type == 100 then --布阵阵法
            JumpController:getInstance():jumpViewByEvtData({30})
        elseif evt_type == 120 then --召唤
            JumpController:getInstance():jumpViewByEvtData({1})
        elseif evt_type == 121 then --背包 碎片
            JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.HERO})
        elseif evt_type == 122 then --英雄商城
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.Recovery})
        elseif evt_type == 123 or evt_type == 162 then --金币兑换
            JumpController:getInstance():jumpViewByEvtData({35})
        elseif evt_type == 125 then --金币出售

        elseif evt_type == 126 then --远航
            JumpController:getInstance():jumpViewByEvtData({18})
        elseif evt_type == 128 then --银币摆摊

        elseif evt_type == 129 then --日常
            JumpController:getInstance():jumpViewByEvtData({41})
        elseif evt_type == 130 then --成就
            JumpController:getInstance():jumpViewByEvtData({41, TaskConst.type.feat})
        elseif evt_type == 131 then --充值
            JumpController:getInstance():jumpViewByEvtData({7})
        elseif evt_type == 132 then --快速作战
            JumpController:getInstance():jumpViewByEvtData({11})
        elseif evt_type == 134 then --杂货店
            JumpController:getInstance():jumpViewByEvtData({6})
        elseif evt_type == 135 then --金币市场 突破
        
        elseif evt_type == 138 then --钻石商城
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.GodShop})
        elseif evt_type == 144 then --道具背包
            JumpController:getInstance():jumpViewByEvtData({8, BackPackConst.item_tab_type.PROPS})
        elseif evt_type == 145 then --联盟捐献
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo:isHasGuild() then
                JumpController:getInstance():jumpViewByEvtData({13})
            else
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
            end
        elseif evt_type == 146 then --公会副本
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo:isHasGuild() then
                JumpController:getInstance():jumpViewByEvtData({31})
            else
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.guild)
            end
        elseif evt_type == 150 then --星河神殿
            JumpController:getInstance():jumpViewByEvtData({27})
        elseif evt_type == 151 then --英雄远征
            JumpController:getInstance():jumpViewByEvtData({25})
        elseif evt_type == 152 then --日常副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.dungeonstone) 
        elseif evt_type == 153 then --无尽试炼
            local open_data = Config.DailyplayData.data_exerciseactivity[2]
            if open_data == nil then
                message(TI18N("无尽试炼数据异常"))
                return
            end
            local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
            if bool == false then 
                message(open_data.lock_desc)
                return 
            end
            local is_open = Endless_trailController:getInstance():checkIsOpen()
            if is_open then
                JumpController:getInstance():jumpViewByEvtData({43})
            end
        elseif evt_type == 154 then --锻造屋
            JumpController:getInstance():jumpViewByEvtData({26})
        elseif evt_type == 155 then --融合祭坛
            JumpController:getInstance():jumpViewByEvtData({23})
        elseif evt_type == 156 then --祭祀小屋
            JumpController:getInstance():jumpViewByEvtData({22})
        elseif evt_type == 157 then -- 剧情副本
            JumpController:getInstance():jumpViewByEvtData({5})
        elseif evt_type == 158 then -- 竞技场
            JumpController:getInstance():jumpViewByEvtData({3})
        elseif evt_type == 159 then -- 冠军赛
            JumpController:getInstance():jumpViewByEvtData({36})
        elseif evt_type == 160 then -- 试练塔
            JumpController:getInstance():jumpViewByEvtData({12})
        elseif evt_type == 402 then -- 好友
            JumpController:getInstance():jumpViewByEvtData({4})
        elseif evt_type == 404 then --英雄界面
            JumpController:getInstance():jumpViewByEvtData({19})
        elseif evt_type == 405 then --幸运探宝
            JumpController:getInstance():jumpViewByEvtData({40})
        elseif evt_type == 406 then --探宝商店
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.GuessShop})
        elseif evt_type == 407 then --冒险
            JumpController:getInstance():jumpViewByEvtData({34})
        elseif evt_type == 408 or evt_type == 161 then --锻造坊的符文
            JumpController:getInstance():jumpViewByEvtData({26, ForgeHouseConst.Tab_Index.Artifact})
        elseif evt_type == 409 then
            JumpController:getInstance():jumpViewByEvtData({20})
        elseif evt_type == 410 then --精英段位赛商店
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.EliteShop})
        elseif evt_type == 411 then --限时召唤
            local data = {MainuiConst.icon.festival, ActionRankCommonType.select_elite_summon}
            JumpController:getInstance():jumpViewByEvtData({45, data})
        elseif evt_type == 412 then --打开录像馆
            VedioController:getInstance():openVedioMainWindow(true)
        elseif evt_type == 413 then --打开录像馆个人记录
            VedioController:getInstance():openVedioMyselfWindow(true)
        elseif evt_type == 414 then --元素神殿
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.elementWar)
        elseif evt_type == 415 then --试炼之境
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.limitexercise)
        elseif evt_type == 416 then --荣誉墙
            RoleController:getInstance():openRolePersonalSpacePanel(true, {index = RoleConst.Tab_type.eHonorWall})
        elseif evt_type == 417 then --成长之路
            RoleController:getInstance():openRolePersonalSpacePanel(true, {index = RoleConst.Tab_type.eGrowthWay})
        elseif evt_type == 418 then --家园
            HomeworldController:getInstance():requestOpenMyHomeworld(  )
        elseif evt_type == 419 then -- 公会
            JumpController:getInstance():jumpViewByEvtData({14})
        elseif evt_type == 420 then -- 进阶历练
            JumpController:getInstance():jumpViewByEvtData({41, TaskConst.type.exp})
        elseif evt_type == 421 then --神器精炼
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.hallows, nil, {0, HallowsConst.Tab_Index.refine})
        elseif evt_type == 422 then --周冠军赛
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.crosschampion)
        elseif evt_type == 423 then --精灵
            JumpController:getInstance():jumpViewByEvtData({60})
        elseif evt_type == 424 then --公会秘境
            JumpController:getInstance():jumpViewByEvtData({62})
        elseif evt_type == 425 then --神装祈祷界面（天界祈祷）
            JumpController:getInstance():jumpViewByEvtData({48})
        elseif evt_type == 426 then --神装洗练界面
            JumpController:getInstance():jumpViewByEvtData({8,BackPackConst.item_tab_type.HOLYEQUIPMENT})
        elseif evt_type == 427 then --先知殿 转换
            JumpController:getInstance():jumpViewByEvtData({24,2})
        elseif evt_type == 428 then --超凡段位赛
            JumpController:getInstance():jumpViewByEvtData({28})
        elseif evt_type == 429 then --神装副本（天界副本）
            JumpController:getInstance():jumpViewByEvtData({47})
        elseif evt_type == 430 then --组队竞技场
            JumpController:getInstance():jumpViewByEvtData({65})
        elseif evt_type == 431 then --多人竞技场
            JumpController:getInstance():jumpViewByEvtData({76})
        end
    end
end

function StrongerController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end