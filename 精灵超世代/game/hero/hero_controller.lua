-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      宝可梦控制器, 客户端 lwc 策划 星宇 后端 锋林
-- <br/>Create: 2018-11-14
-- --------------------------------------------------------------------
HeroController = HeroController or BaseClass(BaseController)

function HeroController:config()
    self.model = HeroModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HeroController:getModel()
    return self.model
end

function HeroController:registerEvents()
    -- 断线重连重置一下伙伴及其装备缓存数据
    if self.re_link_game_event == nil then
        self.re_link_game_event = self.dispather:Bind(LoginEvent.RE_LINK_GAME, function()
            self.model:resetAllData()
            self:openEquipTips(false)
            --[[self:sender11000()
            self:sender11040()
            self:sender11037()
            --请求阵法
            self:sender11213({{type = PartnerConst.Fun_Form.Drama}, {type = PartnerConst.Fun_Form.Arena}})--]]
        end)
    end

    --角色数据创建完毕后，监听资产数据变化情况
    if not self.role_create_success then 
        self.role_create_success = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS,function()
            GlobalEvent:getInstance():UnBind(self.role_create_success)
            self.role_create_success = nil

            --[[self:sender11000()
            self:sender11040()
            self:sender11037()
            --请求阵法
            self:sender11213({{type = PartnerConst.Fun_Form.Drama}, {type = PartnerConst.Fun_Form.Arena}})--]]
            self.role_vo = RoleController:getInstance():getRoleVo()
            self.model.record_login_lev = self.role_vo.lev
            if self.role_vo ~= nil then
                if self.role_lev_event == nil then
                    self.role_lev_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                        if key == "coin" then
                            self.model:checkLevelRedPointUpdate()
                            if self.model.checkResonateRedPoint then --bugly 上面提示这里有错.先弄容错看还会不会出现
                                self.model:checkResonateRedPoint()
                            end
                        elseif key == "hero_exp" then
                            self.model:checkLevelRedPointUpdate()
                        -- elseif key == "boss_point" then
                        elseif key == "lev" then
                            self.model:checkUnlockFormRedPoint(lev)
                        end
                    end)
                end
            end
        end)
    end
    --物品道具增加 判断红点
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code == BackPackConst.Bag_Code.EQUIPS then 
                self.model.is_equip_redpoint_bag_update = true
                self.model:checkEquipRedPointUpdate()
            else
                local is_check_hero = false
                for i,item in pairs(temp_add) do
                    if item.base_id == self.model.upgrade_star_cost_id or item.base_id == self.model.upgrade_star_cost_id_2 then
                        self.model.is_upgradestar_redpoint_bag_update = true
                        self.model:checkUpgradeStarRedPointUpdate()
                        self.model:checkLevelRedPointUpdate()
                    elseif item.base_id == self.model.talent_skill_cost_id then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end
                    if Config.ItemData.data_skill_item_list[item.base_id] then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end
                    if item.config and item.config.type == BackPackConst.item_type.HERO_HUN then
                        is_check_hero = true
                    end
                end
                if is_check_hero and self.model.checkHeroChangeRedPoint then
                    self.model:checkHeroChangeRedPoint()
                end

                --共鸣水晶红点
                if self.model.checkResonateRedPoint then --bugly 上面提示这里有错.先弄容错看还会不会出现
                    self.model:checkResonateRedPoint()
                end
            end
        end)
    end
    --物品道具删除 判断红点
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code == BackPackConst.Bag_Code.EQUIPS then
                self.model.is_equip_redpoint_bag_update = true
                self.model:checkEquipRedPointUpdate()
            else
                local is_check_hero = false
                for i,item in pairs(temp_del) do
                    if item.base_id == self.model.upgrade_star_cost_id or item.base_id == self.model.upgrade_star_cost_id_2 then
                        self.model.is_upgradestar_redpoint_bag_update = true
                        self.model:checkUpgradeStarRedPointUpdate()
                        self.model:checkLevelRedPointUpdate()
                    elseif item.base_id == self.model.talent_skill_cost_id then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end
                    if Config.ItemData.data_skill_item_list[item.base_id] then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end

                    if item.config and item.config.type == BackPackConst.item_type.HERO_HUN then
                        is_check_hero = true
                    end
                end
                if is_check_hero and self.model.checkHeroChangeRedPoint then
                    self.model:checkHeroChangeRedPoint()
                end
                --共鸣水晶红点
                if self.model.checkResonateRedPoint then --bugly 上面提示这里有错.先弄容错看还会不会出现
                    self.model:checkResonateRedPoint()
                end
            end
        end)
    end

    --物品道具改变 判断红点
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code == BackPackConst.Bag_Code.EQUIPS then 
                self.model.is_equip_redpoint_bag_update = true
                self.model:checkEquipRedPointUpdate()
            else
                local is_check_hero = false
                for i,item in pairs(temp_list) do
                    if item.base_id == self.model.upgrade_star_cost_id or item.base_id == self.model.upgrade_star_cost_id_2 then
                        self.model.is_upgradestar_redpoint_bag_update = true
                        self.model:checkUpgradeStarRedPointUpdate()
                        self.model:checkLevelRedPointUpdate()
                    elseif item.base_id == self.model.talent_skill_cost_id then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end
                    if Config.ItemData.data_skill_item_list[item.base_id] then
                        self.model:setUpdateTalentRedpoint()
                        self.model:checkTalentRedPointUpdate()
                    end
                    if item.config and item.config.type == BackPackConst.item_type.HERO_HUN then
                        is_check_hero = true
                    end
                end
                if is_check_hero and self.model.checkHeroChangeRedPoint then
                    self.model:checkHeroChangeRedPoint()
                end
                --共鸣水晶红点 
                if self.model.checkResonateRedPoint then --bugly 上面提示这里有错.先弄容错看还会不会出现
                    self.model:checkResonateRedPoint()
                end
            end
        end)
    end

    -- 激活神器(圣器) 判断红点
    if self.update_drama_hallows_event == nil then
        if HallowsEvent then
            self.update_drama_hallows_event = GlobalEvent:getInstance():Bind(HallowsEvent.HallowsActivityEvent, function()
                self.model:checkUnlockHallowsRedPoint()
            end)
        end
    end
end

function HeroController:registerProtocals()
    self:RegisterProtocal(11000, "handle11000")     --请求所有伙伴
    
    self:RegisterProtocal(11025, "handle11025")     --请求所有伙伴基本信息
    self:RegisterProtocal(11026, "handle11026")     --根据列表请求伙伴的详细信息

    self:RegisterProtocal(11001, "handle11001")     --伙伴增加
    self:RegisterProtocal(11002, "handle11002")     --伙伴属性变更通知(单个伙伴属性)
    self:RegisterProtocal(11007, "handle11007")     --伙伴属性变更通知(list列表伙伴属性)

    --升级
    self:RegisterProtocal(11003, "handle11003")     --伙伴升级
    self:RegisterProtocal(11004, "handle11004")     --伙伴进阶
    self:RegisterProtocal(11005, "handle11005")     --伙伴升星
    self:RegisterProtocal(11006, "handle11006")     --删除伙伴推送


    self:RegisterProtocal(11009, "handle11009")     --购买宝可梦数量上限
    self:RegisterProtocal(11016, "handle11016")     --伙伴下一阶属性
    self:RegisterProtocal(11017, "handle11017")     --推送伙伴最新数量
        -- --装备相关
    self:RegisterProtocal(11010, "handle11010")     --穿戴装备
    self:RegisterProtocal(11011, "handle11011")     --卸下装备
    self:RegisterProtocal(11012, "handle11012")     --推送装备改变
    -- self:RegisterProtocal(11013, "handle11013")     --装备精炼
    -- self:RegisterProtocal(11014, "handle11014")     --一键精炼
    
    self:RegisterProtocal(11015, "handle11015")     --宝可梦锁定


    self:RegisterProtocal(11055, "handle11055")     --融合升星红点处理
    self:RegisterProtocal(11056, "handle11056")     --请求融合升星红点

    --请求阵法
    -- self:RegisterProtocal(11200, "handle11200")     --请求自身阵法
    -- self:RegisterProtocal(11201, "handle11201")     --更换自身阵法
    -- self:RegisterProtocal(11202, "handle11202")     --伙伴上阵/下阵/交换
    -- self:RegisterProtocal(11203, "handle11203")     --阵法数据改变推送
    -- self:RegisterProtocal(11204, "handle11204")     --阵法升级/激活
    self:RegisterProtocal(11211, "handle11211")     --请求队伍
    self:RegisterProtocal(11212, "handle11212")     --请求保存队伍协议
    self:RegisterProtocal(11213, "handle11213")     --请求多个队伍

    -- --符文相关
    self:RegisterProtocal(11030, "handle11030")     --符文穿戴
    self:RegisterProtocal(11031, "handle11031")     --推送符文改变
    self:RegisterProtocal(11032, "handle11032")     --符文升星
    self:RegisterProtocal(11033, "handle11033")     --符文重置
    self:RegisterProtocal(11034, "handle11034")     --符文重铸保存
    self:RegisterProtocal(11035, "handle11035")     --符文碎片合成
    self:RegisterProtocal(11036, "handle11036")     --符文合成
    self:RegisterProtocal(11037, "handle11037")     --符文祝福值
    self:RegisterProtocal(11038, "handle11038")     --领取符文祝福值
    self:RegisterProtocal(11048, "handle11048")     --符文重铸次数

    self:RegisterProtocal(11040, "handle11040")     --宝可梦图鉴信息
    self:RegisterProtocal(11060, "handle11060")     --宝可梦图鉴信息

    self:RegisterProtocal(11063, "handle11063")     --宝可梦详细信息

    self:RegisterProtocal(11075, "handle11075")     --请求宝可梦遣散 分解材料
    self:RegisterProtocal(11087, "handle11087")     --请求宝可梦升星的材料
    self:RegisterProtocal(11076, "handle11076")     --宝可梦遣散 分解

    --天赋相关
    self:RegisterProtocal(11096, "handle11096")     --学习天赋技能
    self:RegisterProtocal(11097, "handle11097")     --天赋技能升级
    self:RegisterProtocal(11098, "handle11098")     --天赋遗忘
    self:RegisterProtocal(11099, "handle11099")     --获取宝可梦天赋信息

    --神装相关
    self:RegisterProtocal(11090, "handle11090")     --神装保存重置技能
    self:RegisterProtocal(11091, "handle11091")     --推送神装改变
    self:RegisterProtocal(11092, "handle11092")     --请求神装穿戴信息
    self:RegisterProtocal(11093, "handle11093")     --神装穿戴/卸下
    self:RegisterProtocal(11094, "handle11094")     --神装重置

    self:RegisterProtocal(11088, "handle11088")     --神装获取出售材料
    self:RegisterProtocal(11089, "handle11089")     --神装出售
    self:RegisterProtocal(11086, "handle11086")     --神装预览属性返回

    self:RegisterProtocal(25220, "handle25220")     --当前神装套装状态
    self:RegisterProtocal(25221, "handle25221")     --新增神装套装
    -- self:RegisterProtocal(25222, "handle25222")     --更新某个神装套装状态 服务器已弃用
    self:RegisterProtocal(25223, "handle25223")     --购买新的格子
    self:RegisterProtocal(25224, "handle25224")     --应用方案到宝可梦

    self:RegisterProtocal(11019, "handle11019")     --皮肤使用
    self:RegisterProtocal(11020, "handle11020")     --皮肤预览


    --共鸣
    self:RegisterProtocal(26400, "handle26400")     --共鸣石碑信息    
    self:RegisterProtocal(26401, "handle26401")     --共鸣石碑上阵/下阵 (成功推送26400)    
    self:RegisterProtocal(26402, "handle26402")     --共鸣石碑升级(成功推送26400)    

    self:RegisterProtocal(26410, "handle26410")     --共鸣提炼魔液信息    
    self:RegisterProtocal(26411, "handle26411")     --设置共鸣石碑提炼(成功推送26410)
    self:RegisterProtocal(26412, "handle26412")     --取消共鸣石碑提炼(成功推送26410)    
    self:RegisterProtocal(26413, "handle26413")     --共鸣石碑提炼收获(成功推送26410)
    self:RegisterProtocal(26414, "handle26414")     --共鸣石碑提炼红点

    self:RegisterProtocal(26420, "handle26420")     --当前可共鸣到的星级（改变石碑布阵会主动推）
    self:RegisterProtocal(26421, "handle26421")     --共鸣赋能
    self:RegisterProtocal(26422, "handle26422")     --共鸣赋能
    self:RegisterProtocal(26423, "handle26423")     --计算赋能宝可梦战力
    self:RegisterProtocal(26424, "handle26424")     --弹出获得的赋能宝可梦

    self:RegisterProtocal(26425, "handle26425")     --水晶信息
    self:RegisterProtocal(26426, "handle26426")     --放入共鸣宝可梦
    self:RegisterProtocal(26427, "handle26427")     --卸下共鸣宝可梦
    self:RegisterProtocal(26428, "handle26428")     --刷新槽位冷却时间
    self:RegisterProtocal(26429, "handle26429")     --解锁共鸣槽位
    self:RegisterProtocal(26430, "handle26430")     --水晶升级
    self:RegisterProtocal(26431, "handle26431")     --请求水晶升级后的共鸣宝可梦总战力
    self:RegisterProtocal(26432, "handle26432")     --请求水晶突破


    --还有一个 11071 重生的 (针对于活动的)
    --重生(针对高星的)
    self:RegisterProtocal(11065, "handle11065")     --伙伴回退
    self:RegisterProtocal(11066, "handle11066")     --宝可梦回退返回材料

    --重生(针对 100级一下的宝可梦)
    self:RegisterProtocal(11067, "handle11067")     --宝可梦重生信息
    self:RegisterProtocal(11068, "handle11068")     --宝可梦重生

end

--0点更新
function HeroController:zeroUpdata()
    self:sender11056() -- 申请融化祭坛红点
    self:sender26420() -- 共鸣赋能更新次数
    self.model:removeResetTimeInfo()
    if self.hero_main_info_window then
        self.hero_main_info_window:sendRssetTimeProto()
    end
    if self.hero_reset_comfirm_panel then
        self:openHeroResetComfirmPanel(false)
    end
end

-----------------------宝可梦伙伴相关--------------------------------
--请求伙伴所有数据(2019年5月8日已经弃用 , 用 11025, 11026) (先保留测试需要)
-- function HeroController:sender11000()
--     -- print("---------登陆发送协议 11000")
--     local protocal ={}
--     self:SendProtocal(11000,protocal)
-- end

function HeroController:handle11000(data)
    -- dump(data, "11000 协议===================>")
    self.model:setHeroMaxCount(data.num)
    self.model:setHeroBuyNum(data.buy_num)
    self.model:updateHeroList(data.partners)
    --伙伴数据请求完成判断一次图鉴红点
    -- PokedexController:getInstance():checkIsCanCall()

    -- 计算一下圣物红点
    -- HalidomController:getInstance():getModel():calculateHalidomRedStatus()

    --宝可梦信息有了 可以初始化精英赛布阵信息了
    ElitematchController:getInstance():loginSendProtoInfo()

    --申请所拥有的皮肤信息
    self:sender11020()
end

--请求伙伴所有基本数据  在 function SysController:requestLoginProtocals(  ) 统一请求
-- function HeroController:sender11025()
--     local protocal ={}
--     self:SendProtocal(11025,protocal)
-- end

function HeroController:handle11025(data)
    -- dump(data, "handle11025 协议===================>")
    self.model:setHeroMaxCount(data.num)
    self.model:setHeroBuyNum(data.buy_num)
    self.model:updateHeroList(data.partners)

    -- 计算一下圣物红点
    -- HalidomController:getInstance():getModel():calculateHalidomRedStatus()

    --宝可梦信息有了 可以初始化精英赛布阵信息了
    ElitematchController:getInstance():loginSendProtoInfo()

    --申请11026协议去
    self.model:batchSendHeroInfo()

    --拉取神装套装信息
    self:sender25220() 
    --申请所拥有的皮肤信息
    self:sender11020()
    --共鸣信息
    self:sender26400()
    self:sender26410()
    --原力水晶
    self:sender26425()

    --申请所有宝可梦的神装信息
    self.model:sendAllHeroHolyEquipInfo()

    GlobalEvent:getInstance():Fire(HeroEvent.All_Hero_Base_Info_Event)
end

--根据列表请求伙伴所有详细信息
function HeroController:sender11026(list)
    local protocal ={}
    protocal.partner_ids = list
    self:SendProtocal(11026,protocal)
end

function HeroController:handle11026(data)
    self.model:updateHeroList(data.partners, true, true)
    GlobalEvent:getInstance():Fire(HeroEvent.All_Hero_Detail_Info_Event)
end

-- --伙伴增加通知
function HeroController:handle11001( data )
    self.model:updateHeroList(data.partners)

    if self.model.checkHeroChangeRedPoint then
        self.model:checkHeroChangeRedPoint()
    end
    -- 计算一下圣物红点
    HalidomController:getInstance():getModel():calculateHalidomRedStatus()

    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Data_Add, data_list)
end

--伙伴属性变更(单个伙伴属性)
function HeroController:handle11002( data )
    self.model:updateHeroVo(data)
end

--伙伴属性变更(list列表伙伴属性)
function HeroController:handle11007( data )
    RoleController:getInstance():showPower(true)
    self.model:updateHeroList(data.ref_partners, true, true)
end


--伙伴升级
function HeroController:sender11003(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11003,protocal)
end

function HeroController:handle11003( data )
    message(data.msg)
    if data.result == TRUE then
        --升级成功
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Level_Up_Success_Event)
    end
end

--伙伴进阶
function HeroController:sender11004(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11004,protocal)
end

function HeroController:handle11004( data )
    message(data.msg)
    if data.result == TRUE then
        --进阶成功要关闭当前窗口
        self:openHeroBreakPanel(false)
    end
end

--伙伴升星
function HeroController:sender11005(partner_id, hero_list, random_list, item_expend)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.expend1 = hero_list
    protocal.expend2 = random_list
    protocal.item_expend = item_expend
    self:SendProtocal(11005,protocal)
end

function HeroController:handle11005( data )
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Upgrade_Star_Success_Event)
    else
        self.model:setUpgradeStarUpdateRecord(true)
    end
end

--删除伙伴推送
function HeroController:handle11006( data )
    self.model:delHeroDataList(data.expend2)
    -- 计算一下圣物红点
    HalidomController:getInstance():getModel():calculateHalidomRedStatus()
end

--购买宝可梦数量上限
function HeroController:sender11009(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11009,protocal)
end

function HeroController:handle11009(data)
    message(data.msg)
    if data.result == TRUE then
        self.model:setHeroMaxCount(data.num)
        self.model:setHeroBuyNum(data.buy_num)
        GlobalEvent:getInstance():Fire(HeroEvent.Buy_Hero_Max_Count_Event)
    end
end
--获取下一阶 信息
function HeroController:sender11016(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11016,protocal)
end

function HeroController:handle11016(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Next_Break_Info_Event, data)
end

--更新宝可梦数量
function HeroController:handle11017(data)
    self.model:setHeroMaxCount(data.num)
end

--宝可梦图鉴的
function HeroController:sender11040()
    local protocal ={}
    self:SendProtocal(11040,protocal)
end
function HeroController:handle11040( data )
    self.model:setHadHeroInfo(data.partners)
    GlobalEvent:getInstance():Fire(HeroEvent.Get_Had_Hero_Star_Event)
end

--融合升星红点处理 是否要红点(0:不用 1:要)"}
function HeroController:sender11055(is_point)
    if is_point == 0 then
        self.model:setIsFuseRedPoint(false)
        self.model:recordFuseRedPointInfo()
    end
    self.model:setIsFuseRedPoint(is_point == 1)

    local protocal ={}
    protocal.is_point = is_point
    self:SendProtocal(11055,protocal)
end

function HeroController:handle11055( data )

end

--请求融合升星红点 登陆获取
function HeroController:sender11056()
    local protocal ={}
    self:SendProtocal(11056,protocal)
end

function HeroController:handle11056( data )
    self.model:setIsFuseRedPoint(data.is_point == 1)
    local status = HeroCalculate.checkAllStarFuseRedpoint()
    if data.is_point == 1 then
        --祭坛主城红点
        MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.guild, status)
    else
        self.model:recordFuseRedPointInfo()
    end

end


-- 请求宝可梦分解材料
function HeroController:sender11075(partner_list)
    local protocal ={}
    protocal.list = partner_list
    self:SendProtocal(11075,protocal)
end

function HeroController:handle11075( data )
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Reset_Look_Event, data)
    end
end
-- 请求宝可梦分解材料
function HeroController:sender11087(partner_list)
    local protocal ={}
    protocal.list = partner_list
    self:SendProtocal(11087,protocal)
end

function HeroController:handle11087( data )
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Reset_Star_Event, data)
    end
end

-- 请求宝可梦遣散 分解
function HeroController:sender11076(partner_list)
    local protocal ={}
    protocal.list = partner_list
    self:SendProtocal(11076,protocal)
end

function HeroController:handle11076( data )
    message(data.msg)
    if data.code == TRUE then
        self.model:delHeroDataList(data.list)
    end
end


--宝可梦分享
function HeroController:sender11060(channel,partner_id)
    local protocal ={}
    protocal.channel = channel
    protocal.partner_id = partner_id
    self:SendProtocal(11060,protocal)
end

function HeroController:handle11060( data )
    message(data.msg)
end

--宝可梦信息
function HeroController:sender11063(partner_id)
    local protocal ={}
    protocal.partner_id = partner_id
    self:SendProtocal(11063,protocal)
end

function HeroController:handle11063( data )
    self.model:updateHeroVoDetailedInfo(data)
end
-----------------------宝可梦伙伴相关--------------------------------


---------------------------装备相关------------------------------------
    
--穿戴装备 
--@item_id  0表示一键穿戴
function HeroController:sender11010(partner_id,item_id)
    self.model:setEquipUpdateRecord(false)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.item_id = item_id
    self:SendProtocal(11010,protocal)
end
function HeroController:handle11010( data )
    message(data.msg)
    if data.result == FALSE then
        self.model:setEquipUpdateRecord(true)
    end
end
--卸下装备
--@pos_id  0表示一键穿戴
function HeroController:sender11011(partner_id,pos_id)
    self.model:setEquipUpdateRecord(false)
    local protocal ={}
    protocal.partner_id = partner_id
    --此值改成装备唯一id 
    protocal.pos_id = pos_id 
    self:SendProtocal(11011,protocal)
end
function HeroController:handle11011( data )
    message(data.msg)
    if data.result == FALSE then
        self.model:setEquipUpdateRecord(true)
    end
end
--推送装备改变
function HeroController:handle11012( data )
    message(data.msg)
    self.model:updateHeroEquipList(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Equip_Update_Event)
    
    self.model.is_equip_redpoint_hero_update = true
    self.model:checkEquipRedPointUpdate()
end 

--宝可梦锁定
function HeroController:sender11015(partner_id, is_lock)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.type = is_lock
    self:SendProtocal(11015,protocal)
end

function HeroController:handle11015( data )
    message(data.msg)
    if data.result == TRUE then
        self.model:setLockByPartnerid(data.partner_id, data.type)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Lock_Event)
    end
end
---------------------------装备相关结束------------------------------------

---------------------------神器相关------------------------------------
--伙伴神器相关
--神器穿戴/卸下
function HeroController:sender11030(partner_id,pos_id,artifact_id,type)
    self.model:setEquipUpdateRecord(false)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.pos_id = pos_id
    protocal.artifact_id = artifact_id
    protocal.type = type
    self:SendProtocal(11030,protocal)
end
function HeroController:handle11030( data )
    message(data.msg)

    if data.result == FALSE then
        self.model:setEquipUpdateRecord(true)
    else
        self.model:clearHeroVoDetailedInfoByPartnerID(data.partner_id)
    end
end
--推送神器变化
function HeroController:handle11031( data )
    message(data.msg)
    self.model:updatePartnerArtifactList(data)
    
    -- self.model.is_equip_redpoint_hero_update = true
    -- self.model:checkEquipRedPointUpdate()
end
--神器升星
function HeroController:sender11032(partner_id,artifact_id,expends)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.artifact_id = artifact_id
    protocal.expends = expends
    self:SendProtocal(11032,protocal)
end
function HeroController:handle11032( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_UpStar_Event,data)
    end
end
--神器重置
function HeroController:sender11033(partner_id, artifact_id, skills,luck_item)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.artifact_id = artifact_id
    protocal.skills = skills
    protocal.luck_item = luck_item
    self:SendProtocal(11033,protocal)
end
function HeroController:handle11033( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Recast_Event)
    end
end
--神器重置保存
function HeroController:sender11034(partner_id, artifact_id, type)
    local protocal ={}
    protocal.partner_id = partner_id
    protocal.artifact_id = artifact_id
    protocal.type = type
    self:SendProtocal(11034,protocal)
end
function HeroController:handle11034( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Save_Event)
    end
end

--神器分解
function HeroController:sender11035(artifact_id)
    local protocal ={}
    protocal.artifact_id = artifact_id
    self:SendProtocal(11035,protocal)
end
function HeroController:handle11035( data )
    message(data.msg)
    if data.result == 1 then
        
    end
end

-- 符文合成
function HeroController:sender11036( item_id, expends )
    local protocal ={}
    protocal.item_id = item_id
    protocal.expends = expends
    self:SendProtocal(11036, protocal)
end
function HeroController:handle11036( data )
    message(data.msg)
    if data.result == 1 then
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Compound_Event, data.flag)
    end
end

-- 符文祝福值
function HeroController:sender11037(  )
    local protocal ={}
    self:SendProtocal(11037, protocal)
end
function HeroController:handle11037( data )
    if data and data.lucky then
        self.model:setArtifactLucky(data.lucky)
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Lucky_Event)
    end
end

-- 领取符文祝福值
function HeroController:sender11038(  )
    local protocal ={}
    self:SendProtocal(11038, protocal)
end
function HeroController:handle11038( data )
    if data and data.msg then
        message(data.msg)
    end
end

-- 请求符文重铸次数相关数据
function HeroController:sender11048(  )
    self:SendProtocal(11048, {})
end
function HeroController:handle11048( data )
    if data and data.artifact_ref_count then
        self.model:updateArtifactRecastCount(data.artifact_ref_count)
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Recast_Count_Event)
    end
end

---------------------------神器相关结束------------------------------------

--:请求布阵信息
function HeroController:sender11211(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(11211, protocal)
end
function HeroController:handle11211(data)
    if data.type == PartnerConst.Fun_Form.Drama or
      data.type == PartnerConst.Fun_Form.Arena or
      data.type == PartnerConst.Fun_Form.ArenaTeam  then
        self.model:setFormList(data)
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Update_Fun_Form, data) 
end

--:请求多个布阵信息 11213
function HeroController:sender11213(type_list)
    local protocal = {}
    protocal.type_list = type_list
    self:SendProtocal(11213, protocal)
end

function HeroController:handle11213(data)
    for i,fdata in ipairs(data.info) do
        if fdata.type == PartnerConst.Fun_Form.Drama or
            fdata.type == PartnerConst.Fun_Form.Arena or
            fdata.type == PartnerConst.Fun_Form.ArenaTeam then
            self.model:setFormList(fdata)
        end
    end
end


--:请求保存布阵信息
function HeroController:sender11212(type, formation_type, pos_info, hallows_id)
    local protocal = {}
    protocal.type = type
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info
    protocal.hallows_id = hallows_id
    self:SendProtocal(11212, protocal)
end
function HeroController:handle11212(data)
    if data.code == TRUE then
        if data.type == PartnerConst.Fun_Form.Drama then
             local list = {}
            table.insert(list, {type = PartnerConst.Fun_Form.Drama})
            table.insert(list, {type = PartnerConst.Fun_Form.Arena})
            self:sender11213(list)
        elseif data.type == PartnerConst.Fun_Form.Arena then
            self:sender11211(data.type)
        elseif data.type == PartnerConst.Fun_Form.LimitExercise then
            LimitExerciseController:getInstance():checkJoinFight()
        elseif data.type == PartnerConst.Fun_Form.Sandybeach_boss then
            ActionController:getInstance():checkJoinFight()
        elseif data.type == PartnerConst.Fun_Form.ArenaTeam then
            self:sender11211(data.type)
            GlobalEvent:getInstance():Fire(ArenateamEvent.ARENATEAM_REFRESH_TEAM_INFO_EVENT, data)
        elseif data.type == PartnerConst.Fun_Form.YearMonster then --年兽活动需要更新布阵信息
            self:sender11211(data.type)
        elseif data.type == PartnerConst.Fun_Form.ArenaManyPeople then --多人竞技场
            self:sender11211(data.type)
        end
        GlobalEvent:getInstance():Fire(HeroEvent.Update_Save_Form, data)
    else
        message(data.msg)
    end
end


---------------------------阵法相关结束------------------------------------


---------------------------天赋相关开始-----------------------------------------
--:学习天赋技能
function HeroController:sender11096(partner_id, pos, skill_id)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.pos = pos
    protocal.skill_id = skill_id
    self:SendProtocal(11096, protocal)
end

function HeroController:handle11096(data)
    if data.result == TRUE then
        self.model:updateHeroVoTalent({data}, true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Learn_Talent_Event, data)
    else
        message(data.msg)
    end
end

--天赋技能升级
function HeroController:sender11097(partner_id, pos)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.pos = pos
    self:SendProtocal(11097, protocal)
end

function HeroController:handle11097(data)
    if data.result == TRUE then
        self.model:updateHeroVoTalent({data}, true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Level_Up_Talent_Event, data)
    else
        message(data.msg)
    end
end

--天赋遗忘
function HeroController:sender11098(partner_id, pos)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.pos = pos
    self:SendProtocal(11098, protocal)
end

function HeroController:handle11098(data)
    if data.result == TRUE then
        self.model:updateHeroVoTalent({data}, true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Forget_Talent_Event, data)
    else
        message(data.msg)
    end
end
--获取宝可梦天赋信息
function HeroController:sender11099(list)
    local protocal = {}
    protocal.partner_ids = list
    self:SendProtocal(11099, protocal)
end

function HeroController:handle11099(data)
    self.model:updateHeroVoTalent(data.partner_ids)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Get_Talent_Event, data.partner_ids)
end
---------------------------天赋相关结束-----------------------------------------
---------------------------神装相关结束-----------------------------------------
--神装保存重置技能"
function HeroController:sender11090(partner_id, holy_eqm_id, _type)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.holy_eqm_id = holy_eqm_id --神装id
    protocal.type = _type     
    self:SendProtocal(11090, protocal)
end

function HeroController:handle11090(data)
    message(data.msg)
end

--推送神装改变"
function HeroController:handle11091(data)
    self.model:updateHolyEquipmentInfo(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Holy_Equipment_Update_Event, data)
end
 --请求神装穿戴信息""
function HeroController:sender11092(partner_ids)
    local protocal = {}
    protocal.partner_ids = partner_ids
    self:SendProtocal(11092, protocal)
end

function HeroController:handle11092(data)
    self.model:updateHeroVoHolyEquipment(data.partner_ids)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Get_Holy_Equipment_Event, data.partner_ids)
end

--神装穿戴/卸下"
function HeroController:sender11093(partner_id, holy_eqm_id, _type)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.holy_eqm_id = holy_eqm_id --神装id
    protocal.type = _type
    self:SendProtocal(11093, protocal)
end

function HeroController:handle11093(data)
    message(data.msg)
    if data.result == FALSE then
        --红点的后面在再说
    end
end

--神装重置"
function HeroController:sender11094(partner_id, holy_eqm_id, pos)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.holy_eqm_id = holy_eqm_id
    protocal.pos = pos
    self:SendProtocal(11094, protocal)
end

function HeroController:handle11094(data)
    message(data.msg)
end

--神装获取出售材料
function HeroController:sender11088(item_ids)
    local protocal = {}
    protocal.item_ids = item_ids
    self:SendProtocal(11088, protocal)
end

function HeroController:handle11088(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Sell_Holy_Equipment_Res_Event, data)
end

--神装出售
function HeroController:sender11089(item_ids)
    local protocal = {}
    protocal.item_ids = item_ids
    self:SendProtocal(11089, protocal)
end

function HeroController:handle11089(data)
    message(data.msg)
end

--神装预览返回
function HeroController:sender11086(partner_id, holyequip_suit_data)
    --记录神装套装数据
    self.holyequip_suit_data = holyequip_suit_data
    local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11086, protocal)
end

function HeroController:handle11086(data)
    self:openHolyequipmentTotalAttrPanel(true, data, self.holyequip_suit_data)
end

--当前神装套装状态
function HeroController:sender25220()
    local protocal = {}
    self:SendProtocal(25220, protocal)
end

function HeroController:handle25220(data)
    self.model:updateHolyEquipmentPlan(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Get_Holy_Equipment_Plan_Event, data)
end

--新增神装套装方案
function HeroController:sender25221(suit_id, partner_id, name, holy_eqm_list)
    local protocal = {}
    protocal.id = suit_id
    protocal.partner_id = partner_id
    protocal.name = name
    protocal.holy_eqm = holy_eqm_list
    self:SendProtocal(25221, protocal)
end

function HeroController:handle25221(data)
    message(data.msg)
end

--更新某个神装套装状态 服务器已弃用
-- function HeroController:sender25222()
--     local protocal = {}
--     self:SendProtocal(25222, protocal)
-- end

-- function HeroController:handle25222(data)
-- end

--购买新的格子
function HeroController:sender25223()
    local protocal = {}
    self:SendProtocal(25223, protocal)
end

function HeroController:handle25223(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateHolyEquipmentPlan(data, true)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Open_Holy_Equipment_Cell_Event, data.num)
    end
end

--应用方案到宝可梦
function HeroController:sender25224(partner_id, suit_id)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.id = suit_id
    self:SendProtocal(25224, protocal)
end

function HeroController:handle25224(data)
    message(data.msg)
end

---------------------------神装协议结束-----------------------------------------

---------------------------皮肤协议结束-----------------------------------------

--皮肤使用
function HeroController:sender11019(partner_id, skin_id)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.skin_id = skin_id
    self:SendProtocal(11019, protocal)
end

function HeroController:handle11019(data)
    message(data.msg)
    if data.result == TRUE then
        message(TI18N("更换成功"))
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Skin_Used_Event, data)
end

--皮肤使用
function HeroController:sender11020()
    local protocal = {}
    self:SendProtocal(11020, protocal)
end

function HeroController:handle11020(data)
    self.model:initHeroSkin(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Skin_Info_Event, data)
end



---------------------------皮肤协议结束-----------------------------------------

---------------------------共鸣协议开始-----------------------------------------
--共鸣石碑信息 
function HeroController:sender26400()
    local protocal = {}
    self:SendProtocal(26400, protocal)
end

function HeroController:handle26400(data)
    self.model:updateResonateLockInfo(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Info_Event, data)
end

--共鸣石碑上阵/下阵 (成功推送26400) 
function HeroController:sender26401(pos, id, _type)
    local protocal = {}
    protocal.pos = pos
    protocal.id = id
    protocal.type = _type
    self:SendProtocal(26401, protocal)
end

function HeroController:handle26401(data)
    message(data.msg)
end

--共鸣石碑升级(成功推送26400)
function HeroController:sender26402()
    local protocal = {}
    self:SendProtocal(26402, protocal)
end

function HeroController:handle26402(data)
    message(data.msg)
end

--共鸣提炼魔液信息    
function HeroController:sender26410()
    local protocal = {}
    self:SendProtocal(26410, protocal)
end

function HeroController:handle26410(data)
    --算红点
    if self.model.checkResonateExtractRedpoint then --buly上面有提示这个为nil 所以加了容错
        self.model:checkResonateExtractRedpoint(data)
    end
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Extract_Event, data)
end

--设置共鸣石碑提炼(成功推送26410)
function HeroController:sender26411(all_num)
    local protocal = {}
    protocal.all_num = all_num
    self:SendProtocal(26411, protocal)
end

function HeroController:handle26411(data)
    message(data.msg)
end

--取消共鸣石碑提炼(成功推送26410) 
function HeroController:sender26412()
    local protocal = {}
    self:SendProtocal(26412, protocal)
end

function HeroController:handle26412(data)
    message(data.msg)
end

--共鸣石碑提炼收获(成功推送26410)
function HeroController:sender26413()
    local protocal = {}
    self:SendProtocal(26413, protocal)
end

function HeroController:handle26413(data)
    message(data.msg)
end
--共鸣石碑提炼点击红点 只需要告诉后端就可以了
function HeroController:sender26414()
    local protocal = {}
    self:SendProtocal(26414, protocal)
end

function HeroController:handle26414(data)
end

--当前可共鸣到的星级（改变石碑布阵会主动推）
function HeroController:sender26420()
    local protocal = {}
    self:SendProtocal(26420, protocal)
end

function HeroController:handle26420(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Empowerment_Event, data)
end

--共鸣赋能"
function HeroController:sender26421(partner_id, skills)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.skills = skills
    self:SendProtocal(26421, protocal)
end

function HeroController:handle26421(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Empowerment_Success_Event, data)
    end
end

--获取已学习的天赋技能列表
function HeroController:sender26422()
    local protocal = {}
    self:SendProtocal(26422, protocal)
end

function HeroController:handle26422(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Skill_List_Event, data)
end

--计算赋能宝可梦战力"
function HeroController:sender26423(partner_id, skills)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.skills = skills
    self:SendProtocal(26423, protocal)
end

function HeroController:handle26423(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Hero_Power_Event, data)
end

--弹出获得的赋能宝可梦"
function HeroController:handle26424(data)
    if data then
        local hero_vo = self.model:getHeroById(data.partner_id)
        if hero_vo then
            local items = {}
            items[1] = deepCopy(hero_vo)
            items[1].show_type = MainuiConst.item_exhibition_type.partner_type

            MainuiController:getInstance():openGetItemView(true, items, 0)
        end
    end
end

--水晶信息"
function HeroController:sender26425()
    local protocal = {}
    self:SendProtocal(26425, protocal)
end

function HeroController:handle26425(data)
    self.model:updateResonateCystalInfo(data)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Info_Event, data)
end

--放入共鸣宝可梦"
function HeroController:sender26426(partner_id, pos)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.pos = pos
    self.put_partner_id = partner_id
    self.put_pos = pos
    self:SendProtocal(26426, protocal)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Can_List_Event, false)
end

function HeroController:handle26426(data)
    message(data.msg)
    if data.result == TRUE then
        local id = data.partner_id or self.put_partner_id 
        local hero_vo = self.model:getHeroById(id)
        if hero_vo and next(hero_vo) ~= nil then
            self:openHeroResonatePutResultPanel(true, hero_vo)
            --可能放入的宝可梦有升级的红点..要消除他
            hero_vo.red_point[HeroConst.RedPointType.eRPLevelUp] = nil 
            --可能是上阵的也要过滤一下
            HeroCalculate.checkAllHeroRedPoint()
        end
        self.put_partner_id = nil
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, self.put_pos)
    end
    self.put_pos = nil
end

--卸下共鸣宝可梦"
function HeroController:sender26427(partner_id, pos)
    local protocal = {}
    protocal.partner_id = partner_id
    protocal.pos = pos
    self.down_pos = pos
    self:SendProtocal(26427, protocal)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Can_List_Event, false)
end

function HeroController:handle26427(data)
    message(data.msg)
    --可能是上阵的也要过滤一下
    if data.result == TRUE then
        HeroCalculate.checkAllHeroRedPoint()
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, self.down_pos)
    end
    self.down_pos = nil
end

--刷新槽位冷却时间"
function HeroController:sender26428(pos)
    local protocal = {}
    protocal.pos = pos
    self:SendProtocal(26428, protocal)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Can_List_Event, false)
end

function HeroController:handle26428(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, data.pos)
    end
end
--解锁共鸣槽位"
function HeroController:sender26429(pos, type)
    local protocal = {}
    protocal.pos = pos
    protocal.type = type
    self:SendProtocal(26429, protocal)
    GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Can_List_Event, false)
end

function HeroController:handle26429(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, data.pos)
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Update_One_Event, data.pos + 1)
    end
end
--水晶升级(成功推送26425)"
function HeroController:sender26430()
    local protocal = {}
    self:SendProtocal(26430, protocal)
end

function HeroController:handle26430(data)
    message(data.msg)
end


--请求水晶升级后的共鸣宝可梦总战力
function HeroController:sender26431()
    local protocal = {}
    self:SendProtocal(26431, protocal)
end

function HeroController:handle26431(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Crystal_Power_Event, data)
    end
end
--请求水晶突破
function HeroController:sender26432()
    local protocal = {}
    self:SendProtocal(26432, protocal)
end

function HeroController:handle26432(data)
    message(data.msg)
    if data.result == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.Hero_Resonate_Break_Event, data)
    end
end
---------------------------共鸣协议结束-----------------------------------------

---------------------------重生协议开始-----------------------------------------

--伙伴回退
function HeroController:sender11065(partner_id)
    local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11065, protocal)
end

function HeroController:handle11065(data)
    if data then
        message(data.msg)
        local items = {}
        for i,v in ipairs(data.list) do
            if v.is_partner == 1 then
                local hero_vo = self.model:getHeroById(data.partner_id)
                if hero_vo then
                    local hero_info = deepCopy(hero_vo)
                    hero_info.show_type = MainuiConst.item_exhibition_type.partner_type
                    table.insert(items,hero_info)
                end
            else
                table.insert(items, {bid = v.id,num = v.num})
            end
        end
        message(data.msg)
        MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true})
        
        GlobalEvent:getInstance():Fire(HeroEvent.HERO_RESET_EVENT, data)
    end
    
end

--伙伴材料回退
function HeroController:sender11066(partner_id)
    local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11066, protocal)
end

function HeroController:handle11066(data)
    message(data.msg)
    if data and data.code == TRUE then
        GlobalEvent:getInstance():Fire(HeroEvent.HERO_RESET_ITEM_EVENT, data)
    end
end

--重生 针对 100级以下的
function HeroController:sender11067(partner_id)
    local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11067, protocal)
end

function HeroController:handle11067(data)
    self.model:setResetCount(data)
	-- GlobalEvent:getInstance():Fire(HeroEvent.HERO_RESET_100_LEVEL_EVENT, data)
end

--重生 针对 100级以下的
function HeroController:sender11068(partner_id)
    local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11068, protocal)
end

function HeroController:handle11068(data)
    message(data.msg)
end

---------------------------重生协议结束-----------------------------------------


---------------------------其他协议-----------------------------------------

---------------------------其他协议-----------------------------------------

-- 宝可梦(伙伴)背包界面
--@ hero_vo 宝可梦对应数据对象
function HeroController:openHeroBagWindow(status, index, sub_type)
    if status == false then
        if self.hero_bag_window ~= nil then
            self.hero_bag_window:close()
            self.hero_bag_window = nil
        end
    else
        if self.hero_bag_window == nil then
            self.hero_bag_window = HeroBagWindow.New()
        end
        self.hero_bag_window:open(index, sub_type)
    end
end

--打开宝可梦图书馆信息
function HeroController:openHeroLibraryMainWindow(status, bid)
    if status == false then
        if self.hero_library_mainWindow ~= nil then
            self.hero_library_mainWindow:close()
            self.hero_library_mainWindow = nil
        end
    else
        if self.hero_library_mainWindow == nil then
            self.hero_library_mainWindow = HeroLibraryMainWindow.New()
        end
        self.hero_library_mainWindow:open(bid)
    end
end

--打开宝可梦图书馆信息
-- 宝可梦id
function HeroController:openHeroLibraryInfoWindow(status, bid)
    if status == false then
        if self.hero_library_info ~= nil then
            self.hero_library_info:close()
            self.hero_library_info = nil
        end
    else
        if self.hero_library_info == nil then
            self.hero_library_info = HeroLibraryInfoWindow.New()
        end
        self.hero_library_info:open(bid)
    end
end

--打开宝可梦图书馆传记信息
--名字
--传记内容
function HeroController:openHeroLibraryStoryPanel(status, name, content)
    if status == false then
        if self.hero_library_story ~= nil then
            self.hero_library_story:close()
            self.hero_library_story = nil
        end
    else
        if self.hero_library_story == nil then
            self.hero_library_story = HeroLibraryStoryPanel.New()
        end
        self.hero_library_story:open(name, content)
    end
end

-- 宝可梦(伙伴)主信息 界面
--@ hero_vo 宝可梦对应数据对象
--@ hero_list 宝可梦对象列表 
--@ setting 结构
--setting.showType 显示宝可梦新的页签类型
--setting.show_model_type 显示模式 1:宝可梦模式  2:图鉴模式 定义参考 HeroConst.BagTab.eBagHero
function HeroController:openHeroMainInfoWindow(status, hero_vo, hero_list, setting )
    if status == false then
        if self.hero_main_info_window ~= nil then
            self.hero_main_info_window:close()
            self.hero_main_info_window = nil
        end
    else
        if self.hero_main_info_window == nil then
            self.hero_main_info_window = HeroMainInfoWindow.New()
        end
        self.hero_main_info_window:open(hero_vo, hero_list, setting)
    end
end

function HeroController:getHeroMainInfoWindow()
    return self.hero_main_info_window
end

--执行抖动屏幕的动作
function HeroController:runShakeScreemAction()
    local main_ui_controller = MainuiController:getInstance()
    if main_ui_controller.mainui and main_ui_controller.mainui.root_wnd then
        local root_wnd = main_ui_controller.mainui.root_wnd
        -- local start_x, start_y = root_wnd:getPosition()
        -- local moveby = cc.MoveBy:create(0.1, cc.p(0, 50))
        -- local end_moveto = 
        self:shakeScreen(root_wnd)
    end
    if self.hero_main_info_window and self.hero_main_info_window.root_wnd then
        local root_wnd = self.hero_main_info_window.root_wnd
        self:shakeScreen(root_wnd)
    end
end

function HeroController:shakeScreen(scene)
    if scene.action then
        scene.is_shake = false
        scene:stopAllActions()--stopAction(scene.action)
        scene:setPosition(scene.camera_shake_pos)
        scene.action = nil
    end
    scene.camera_shake_pos = cc.p(scene:getPosition())
    scene.is_shake = true
    local function returnPos()
        scene.is_shake = false
        scene:setPosition(scene.camera_shake_pos)
    end
    local order = { 1, 4, 7, 8, 9, 6, 3, 2 }
    local str = 15 --振幅，单位像素
    local damp = 3 --振动减衰, 单位像素
    local step = 0.015 --振动间隔，单位秒
    local shakeXTime = 0.4 --横向加倍
    local shakeYTime = 0.4 --纵向加倍
    local shakeTime =  7 --振动次数
    local xy_list = { {-0.7, 0.7 }, { 0, 1 }, { 0.7, 0.7 }, {-1, 0 }, { 0, 0 }, { 1, 0 }, {-0.7, -0.7 }, { 0, -1 }, { 0.7, -0.7 } }
    local function setRandomPos(index)
        local pos_x, pos_y
        pos_x = str * shakeYTime * xy_list[order[index]][1]
        pos_y = -str * shakeXTime * xy_list[order[index]][2]
        local pos = cc.p(scene.camera_shake_pos.x + pos_x, scene.camera_shake_pos.y + pos_y)
        scene:setPosition(pos)
    end
    local base_call = nil
    for j = 1, shakeTime do
        for i = 1, #order do
            local delay = cc.DelayTime:create(step)
            base_call = cc.Sequence:create(base_call, cc.CallFunc:create(function() setRandomPos(i) end), delay)
        end
        str = str - damp
    end
    base_call = cc.Sequence:create(base_call, cc.CallFunc:create(returnPos))
    scene.action = base_call
    scene:runAction(base_call)
end


--打开立绘界面
--@ draw_res_id 宝可梦绘图资源ID
--@ name 宝可梦名称
--@ bid 宝可梦ID
--@ share_type 绘图分享类型
function HeroController:openHeroLookDrawWindow(status, draw_res_id, name, bid, share_type)
    if status == false then
        if self.hero_look_draw_window ~= nil then
            self.hero_look_draw_window:close()
            self.hero_look_draw_window = nil
        end
    else
        if self.hero_look_draw_window == nil then
            self.hero_look_draw_window = HeroLookDrawWindow.New()
        end
        self.hero_look_draw_window:open(draw_res_id, name, bid, share_type)
    end
end
--打开立绘主界面(整合了皮肤 和立绘界面)
--@ draw_res_id 宝可梦绘图资源ID
--@ name 宝可梦名称
--@ bid 宝可梦ID
--@ share_type 绘图分享类型 --draw_res_id, name, bid, share_type
function HeroController:openHeroDrawMainWindow(status, setting)
    if status == false then
        if self.hero_draw_main_window ~= nil then
            self.hero_draw_main_window:close()
            self.hero_draw_main_window = nil
        end
    else
        if self.hero_draw_main_window == nil then
            self.hero_draw_main_window = HeroDrawMainWindow.New()
        end
        self.hero_draw_main_window:open(setting)
    end
end



--打开进阶界面
function HeroController:openHeroBreakPanel(status, hero_vo)
     if status == false then
        if self.hero_break_panel ~= nil then
            self.hero_break_panel:close()
            self.hero_break_panel = nil
        end
    else
        if self.hero_break_panel == nil then
            self.hero_break_panel = HeroBreakPanel.New()
        end
        self.hero_break_panel:open(hero_vo)
    end
end

--打开进阶成功界面 old_vo new_vo 都是heroVo对象
function HeroController:openBreakExhibitionWindow(status, old_vo,new_vo)
    if status == true then
        if not self.break_exhibition_window then 
            self.break_exhibition_window = HeroBreakExhibitionWindow.New(self)
        end
        if self.break_exhibition_window and self.break_exhibition_window:isOpen() == false then
            self.break_exhibition_window:open(old_vo,new_vo)
        end
    else 
        if self.break_exhibition_window then 
            self.break_exhibition_window:close()
            self.break_exhibition_window = nil
        end

        if old_vo and type(old_vo) =="number" then
            local skill_bid = old_vo
            self:openSkillUnlockWindow(true,skill_bid)
        end
    end
end


--打开升星成功界面 old_vo new_vo 都是heroVo对象
function HeroController:openHeroUpgradeStarExhibitionPanel(status, old_vo,new_vo)
    if status == true then
        BattleResultMgr:getInstance():setWaitShowPanel(true) --让13星礼包等待一下
        if not self.upgrade_star_exhibition_window then 
            self.upgrade_star_exhibition_window = HeroUpgradeStarExhibitionPanel.New(self)
        end
        if self.upgrade_star_exhibition_window and self.upgrade_star_exhibition_window:isOpen() == false then
            self.upgrade_star_exhibition_window:open(old_vo,new_vo)
        end
    else 
        if self.upgrade_star_exhibition_window then 
            self.upgrade_star_exhibition_window:close()
            self.upgrade_star_exhibition_window = nil
        end
    end
end

--打开天赋技能学习面板
function HeroController:openSkillUnlockWindow(status, skill_bid, setting)
    
    if status == true then
        if not self.unlock_window then 
            self.unlock_window = SkillUnlockWindow.New(skill_bid, setting)
        end
        if self.unlock_window and self.unlock_window:isOpen() == false then
            self.unlock_window:open()
        end
    else 
        if self.unlock_window then 
            self.unlock_window:close()
            self.unlock_window = nil
        end
    end
end



--打开宝可梦过滤
function HeroController:openFormFilterHeroPanel(status, dic_filter_camp_type, dic_filter_career_type)
    if status == true then
        if not self.form_filter_hero_panel then 
            self.form_filter_hero_panel = FormFilterHeroPanel.New()
        end
        if self.form_filter_hero_panel and self.form_filter_hero_panel:isOpen() == false then
            self.form_filter_hero_panel:open(dic_filter_camp_type, dic_filter_career_type)
        end
    else 
        if self.form_filter_hero_panel then 
            self.form_filter_hero_panel:close()
            self.form_filter_hero_panel = nil
        end
    end
end



--打开布阵出战界面
--@fun_form_type 布阵队伍类型
--@show_type 出战界面显示类型 1 出战 2 保存布阵
function HeroController:openFormGoFightPanel(status, fun_form_type, setting, show_type)
    if status == true then
        if not self.form_go_fight_panel then 
            self.form_go_fight_panel = FormGoFightPanel.New()
        end
        if self.form_go_fight_panel and self.form_go_fight_panel:isOpen() == false then
            self.form_go_fight_panel:open(fun_form_type, setting, show_type)
        end
    else 
        if self.form_go_fight_panel then 
            self.form_go_fight_panel:close()
            self.form_go_fight_panel = nil
        end
    end
end

--打开布阵 改成和 布阵出战界面 合二为一
function HeroController:openFormMainWindow(status, fun_form_type, setting)
    local setting = setting or {}
    self:openFormGoFightPanel(status, fun_form_type, setting, HeroConst.FormShowType.eFormSave)
end

--打开布阵出战界面 (秘矿冒险专用)
--@fun_form_type 布阵队伍类型
--@show_type 出战界面显示类型 1 出战 2 保存布阵
function HeroController:openAdventureMineFormGoFightPanel(status, fun_form_type, setting, show_type)
    if status == true then
        if not self.adventure_mine_form_go_fight_panel then 
            self.adventure_mine_form_go_fight_panel = FormGoFightPanel.New()
        end
        if self.adventure_mine_form_go_fight_panel and self.adventure_mine_form_go_fight_panel:isOpen() == false then
            self.adventure_mine_form_go_fight_panel:open(fun_form_type, setting, show_type)
        end
    else 
        if self.adventure_mine_form_go_fight_panel then 
            self.adventure_mine_form_go_fight_panel:close()
            self.adventure_mine_form_go_fight_panel = nil
        end
    end
end

--打开选择阵法界面
--@formation_type 阵法类型 也是配置表的id
function HeroController:openFormationSelectPanel(status, formation_type, callback, team_index)
    if status == true then
        if not self.formation_select_panel then 
            self.formation_select_panel = FormationSelectPanel.New()
        end
        if self.formation_select_panel and self.formation_select_panel:isOpen() == false then
            self.formation_select_panel:open(formation_type, callback, team_index)
        end
    else 
        if self.formation_select_panel then 
            self.formation_select_panel:close()
            self.formation_select_panel = nil
        end
    end
end

--打开选择神器界面
-- @hallows_id 神器id
function HeroController:openFormHallowsSelectPanel(status, hallows_id, callback, dic_equips, team_index, mine_hallows_id)
    if status == true then
        if not self.form_hallows_select_panel then 
            self.form_hallows_select_panel = FormHallowsSelectPanel.New()
        end
        if self.form_hallows_select_panel and self.form_hallows_select_panel:isOpen() == false then
            self.form_hallows_select_panel:open(hallows_id, callback, dic_equips, team_index, mine_hallows_id)
        end
    else 
        if self.form_hallows_select_panel then 
            self.form_hallows_select_panel:close()
            self.form_hallows_select_panel = nil
        end
    end
end

--打开宝可梦升星界面 4升5 5升6 融合祭坛
-- function HeroController:openHeroUpgradeStarFuseWindow(status, hero_vo)
--     if status == true then
--         if not self.upgrade_star_fuse_window then 
--             self.upgrade_star_fuse_window = HeroUpgradeStarFusePanel.New()
--         end
--         if self.upgrade_star_fuse_window and self.upgrade_star_fuse_window:isOpen() == false then
--             self.upgrade_star_fuse_window:open(hero_vo)
--         end
--     else 
--         if self.upgrade_star_fuse_window then 
--             self.upgrade_star_fuse_window:close()
--             self.upgrade_star_fuse_window = nil
--         end
--     end
-- end

--@select_data 是模拟hero_vo的数据
--@dic_other_selected 已经其他被选择的数据 [id] = hero_vo模式
--@ form_type --来源位置  1: 表示融合祭坛 2: 表示升星界面的 3:圣物
--@ setting.is_master 是否是主卡(融合祭坛专用)
function HeroController:openHeroUpgradeStarSelectPanel(status, select_data, dic_other_selected, form_type, setting)
    if status == true then
        if not self.upgrade_star_select_panel then 
            self.upgrade_star_select_panel = HeroUpgradeStarSelectPanel.New()
            self.upgrade_star_select_panel:open(select_data, dic_other_selected, form_type, setting)
        else
            if self.upgrade_star_select_panel and self.upgrade_star_select_panel:isOpen() == false then
                self.upgrade_star_select_panel:open()
                self.upgrade_star_select_panel:openRootWnd(select_data, dic_other_selected, form_type, setting)
            end
        end
    else 
        if self.upgrade_star_select_panel then 
            self.upgrade_star_select_panel:close()
            self.upgrade_star_select_panel = nil
        end
    end
end

--打开选择宝可梦界面 和 openHeroUpgradeStarSelectPanel 差不多,,操作上简单很多
function HeroController:openHeroSelectHeroPanel(status, setting)
    if status == true then
        if not self.hero_select_panel then 
            self.hero_select_panel = HeroSelectHeroPanel.New()
            self.hero_select_panel:open(setting)
        else
            if self.hero_select_panel and self.hero_select_panel:isOpen() == false then
                self.hero_select_panel:open()
                self.hero_select_panel:openRootWnd(setting)
            end
        end
    else 
        if self.hero_select_panel then 
            self.hero_select_panel:close()
            self.hero_select_panel = nil
        end
    end
end

-- 打开重生操作界面
function HeroController:openHeroResetWindow(bool, index, hero_vo)
    if bool == false then
        if self.hero_reset_window ~= nil then
            self.hero_reset_window:close()
            self.hero_reset_window = nil
        end
    else
        if self.hero_reset_window == nil then
            self.hero_reset_window = HeroResetWindow.New(index)
        end
        self.hero_reset_window:open(index,hero_vo)
    end
end

-- 分解碎片界面
function HeroController:openBreakChipWindow(status)
    if status == true then
        if not self.break_chip_window then
            self.break_chip_window = HeroChipsBreakWindow.New()
        end
        if self.break_chip_window:isOpen() == false then
            self.break_chip_window:open()
        end
    else
        if self.break_chip_window then
            self.break_chip_window:close()
            self.break_chip_window = nil
        end
    end
end

function HeroController:openHeroResetReturnPanel(bool, item_list)
    if bool == false then
        if self.hero_reset_return_panel ~= nil then
            self.hero_reset_return_panel:close()
            self.hero_reset_return_panel = nil
        end
    else
        if self.hero_reset_return_panel == nil then
            self.hero_reset_return_panel = HeroResetReturnPanel.New()
        end
        self.hero_reset_return_panel:open(item_list)
    end
end


function HeroController:openHeroResetOfferPanel(bool, item_list, is_show_tips, callback, reset_type, dec)
    if bool == false then
        if self.hero_reset_offer_panel ~= nil then
            self.hero_reset_offer_panel:close()
            self.hero_reset_offer_panel = nil
        end
    else
        if self.hero_reset_offer_panel == nil then
            self.hero_reset_offer_panel = HeroResetOfferPanel.New()
        end
        self.hero_reset_offer_panel:open(item_list, is_show_tips, callback, reset_type, dec)
    end
end

--打开装备穿戴界面
function HeroController:openEquipPanel(bool,pos,partner_id,data,holy_data,enter_type)
    if bool == true then
        if not self.equip_panel then 
            self.equip_panel = EquipClothWindow.New(pos,partner_id,data,holy_data,enter_type)
        end
        if self.equip_panel and self.equip_panel:isOpen() == false then
            self.equip_panel:open()
        end
    else 
        if self.equip_panel then 
            self.equip_panel:close()
            self.equip_panel = nil
        end
    end
end

--==============================--
--desc:--打开装备tips
--time:2018-05-24 05:50:42
--@bool:打开与关闭
--@data:装备数据
--@open_type:装备状态，0.其他状态，1: 背包中 3:伙伴身上 具体查看 PartnerConst.EqmTips
--@partner_id:穿戴在伙伴身上就有伙伴id，其他可不填或填0
--@holy_data:神装方案数据
--@return 
--==============================--
function HeroController:openEquipTips(bool,data,open_type,partner,holy_data)
    if bool == true then
        -- 引导的时候不弹
        if GuideController:getInstance():isInGuide() then return end -- 引导的时候不要显示tips了 因为可能会被挡住

        if not self.equip_tips then 
            self.equip_tips = EquipTips.New()
        end
        open_type = open_type or PartnerConst.EqmTips.normal
        if self.equip_tips and self.equip_tips:isOpen() == false then
            self.equip_tips:open({data=data, open_type=open_type, partner=partner, holy_data=holy_data})
        end
    else 
        if self.equip_tips then 
            self.equip_tips:close()
            self.equip_tips = nil
        end
    end
end

----------------------------------------神器相关------------------------------
-- 打开符文重铸界面
function HeroController:openArtifactRecastWindow( status, data, partner_id )
    if status == true then
        if not self.artifact_recast_win then
            self.artifact_recast_win = ArtifactRecastWindow.New()
        end
        if self.artifact_recast_win:isOpen() == false then
            self.artifact_recast_win:open(data, partner_id)
        end
    else
        if self.artifact_recast_win then
            self.artifact_recast_win:close()
            self.artifact_recast_win = nil
        end
    end
end

--打开神器列表选择界面
function HeroController:openArtifactListWindow(bool,artifact_type,partner_id,select_vo)
    if bool == true then
        if not self.artifact_list_panel then 
            self.artifact_list_panel = ArtifactListWindow.New()
        end
        artifact_type = artifact_type or 0
        partner_id = partner_id or 0
        if self.artifact_list_panel and self.artifact_list_panel:isOpen() == false then
            self.artifact_list_panel:open(artifact_type,partner_id,select_vo)
        end
    else 
        if self.artifact_list_panel then 
            self.artifact_list_panel:close()
            self.artifact_list_panel = nil
        end
    end
end

-- 神器选择界面
function HeroController:openArtifactChoseWindow( bool, data )
    if bool == true then
        if not self.artifact_chose_window then
            self.artifact_chose_window = ArtifactChoseWindow.New()
        end
        self.artifact_chose_window:open(data)
    else
        if self.artifact_chose_window then 
            self.artifact_chose_window:close()
            self.artifact_chose_window = nil
        end
    end
end

--==============================--
--desc:打开神器操作界面
--time:2018-05-17 05:34:13
--@bool:
--@data:神器数据，为goods_vo数据
--@open_type:打开类型，分为
--@is_off_tips 是否脱下提示
--@return 
--==============================--
function HeroController:openArtifactTipsWindow(bool,data,open_type,partner_id,pos, is_off_tips, setting)
    if bool == true then
        if data == nil or data.config == nil then
            -- message(TI18N("数据异常"))
            return 
        end
        if not self.artifact_tips_window then 
            self.artifact_tips_window = ArtifactTipsWindow.New()
        end
        open_type = open_type or PartnerConst.ArtifactTips.backpack
        if self.artifact_tips_window and self.artifact_tips_window:isOpen() == false then
            self.artifact_tips_window:open(data,open_type,partner_id,pos,is_off_tips, setting)
        end
    else 
        if self.artifact_tips_window then 
            self.artifact_tips_window:close()
            self.artifact_tips_window = nil
        end
    end
end

-- 打开符文合成tips界面
function HeroController:openArtifactComTipsWindow( status, bid )
    if status == true then
        if not self.artifact_com_win then
            self.artifact_com_win = ArtifactComTipsWindow.New()
        end
        if self.artifact_com_win:isOpen() == false then
            self.artifact_com_win:open(bid)
        end
    else
        if self.artifact_com_win then
            self.artifact_com_win:close()
            self.artifact_com_win = nil
        end
    end
end

-- 打开符文祝福奖励领取界面
function HeroController:openArtifactAwardWindow( status )
    if status == true then
        if not self.artifact_award_win then
            self.artifact_award_win = ArtifactAwardWindow.New()
        end
        if self.artifact_award_win:isOpen() == false then
            self.artifact_award_win:open()
        end
    else
        if self.artifact_award_win then
            self.artifact_award_win:close()
            self.artifact_award_win = nil
        end
    end
end

-- 打开符文技能预览界面
--@show_type 显示类型 1 是符文技能预览 2 是宝可梦天赋技能
--@sub_type 默认选中的标签页下标
function HeroController:openArtifactSkillWindow( status , show_type, sub_type)
    if status then
        if not self.artifact_skill_win then
            self.artifact_skill_win = ArtifactSkillWindow.New()
        end
        if self.artifact_skill_win:isOpen() == false then
            self.artifact_skill_win:open(show_type, sub_type)
        end
    else
        if self.artifact_skill_win then
            self.artifact_skill_win:close()
            self.artifact_skill_win = nil
        end
    end
end

-- 打开符文技能预览界面
function HeroController:openArtifactRecastCostPanel( status)
    if status then
        if not self.artifact_recast_cost_win then
            self.artifact_recast_cost_win = ArtifactRecastCostPanel.New()
        end
        if self.artifact_recast_cost_win:isOpen() == false then
            self.artifact_recast_cost_win:open()
        end
    else
        if self.artifact_recast_cost_win then
            self.artifact_recast_cost_win:close()
            self.artifact_recast_cost_win = nil
        end
    end
end
----------------------------------------神器相关结束------------------------------



-- 打开宝可梦tips界面
function HeroController:openHeroTipsPanel(bool, hero_vo, setting)
    if bool == true then
        if not self.hero_tips_panel then
            self.hero_tips_panel = HeroTipsPanel.New()
        end
        self.hero_tips_panel:open(hero_vo, setting)
    else
        if self.hero_tips_panel then 
            self.hero_tips_panel:close()
            self.hero_tips_panel = nil
        end
    end
end
-- 打开宝可梦属性tips界面
function HeroController:openHeroTipsAttrPanel(bool, hero_vo, is_my)
    if bool == true then
        if not self.hero_tips_attr_panel then
            self.hero_tips_attr_panel = HeroTipsAttrPanel.New()
        end
        self.hero_tips_attr_panel:open(hero_vo, is_my)
    else
        if self.hero_tips_attr_panel then 
            self.hero_tips_attr_panel:close()
            self.hero_tips_attr_panel = nil
        end
    end
end

-- 打开宝可梦tips界面根据bid
function HeroController:openHeroTipsPanelByBid(bid)
    local hero_vo = self.model:getMockHeroVoByBid(bid)
    if hero_vo then
        self:openHeroTipsPanel(true, hero_vo, {is_hide_equip = true})
    end
end

--打开宝可梦图书馆信息根据bid 和星级 is_hide_ui:是否隐藏上下部分的UI
function HeroController:openHeroInfoWindowByBidStar(bid, star, is_hide_ui)
    if not bid or not star then return end
    local key = getNorKey(bid,star)
    local hero_vo = self.model:getHeroPokedexByBid(key)
    if hero_vo then
        self:openHeroMainInfoWindow(true, hero_vo, {hero_vo}, {show_model_type = HeroConst.BagTab.eBagPokedex, is_hide_ui = true} )
    end
end

-- 打开宝可梦学习技能界面
--@pos 技能位置
function HeroController:openHeroTalentSkillLearnPanel(bool, hero_vo, pos)
    if bool == true then
        if not self.hero_talent_skill_panel then
            self.hero_talent_skill_panel = HeroTalentSkillLearnPanel.New()
        end
        self.hero_talent_skill_panel:open(hero_vo, pos)
    else
        if self.hero_talent_skill_panel then 
            self.hero_talent_skill_panel:close()
            self.hero_talent_skill_panel = nil
        end
    end
end
-- 打开宝可梦学习技能升级界面
--@pos 技能位置
function HeroController:openHeroTalentSkillLevelUpPanel(bool, hero_vo, skill_id, pos)
    if bool == true then
        if not self.hero_talent_levelup_panel then
            self.hero_talent_levelup_panel = HeroTalentSkillLevelUpPanel.New()
        end
        self.hero_talent_levelup_panel:open(hero_vo, skill_id, pos)
    else
        if self.hero_talent_levelup_panel then 
            self.hero_talent_levelup_panel:close()
            self.hero_talent_levelup_panel = nil
        end
    end
end
-- 打开宝可梦分享界面..(可通用)
--@world_pos 世界坐标..必填
function HeroController:openHeroSharePanel(bool, world_pos, callback, setting)
    if bool == true then
        if not self.hero_share_panel then
            self.hero_share_panel = HeroSharePanel.New()
        end
        self.hero_share_panel:open(world_pos, callback, setting)
    else
        if self.hero_share_panel then 
            self.hero_share_panel:close()
            self.hero_share_panel = nil
        end
    end
end


--打开神装洗练
--@goods_vo
--@partner_id 宝可梦的 partner_id
function HeroController:openHolyequipmentRefreshAttPanel(bool, goods_vo, partner_id)
    if bool == true then
        if not self.holy_equipment_refresh_att_panel then
            self.holy_equipment_refresh_att_panel = HolyequipmentRefreshAttPanel.New()
        end
        self.holy_equipment_refresh_att_panel:open(goods_vo, partner_id)
    else
        if self.holy_equipment_refresh_att_panel then 
            self.holy_equipment_refresh_att_panel:close()
            self.holy_equipment_refresh_att_panel = nil
        end
    end
end

--打开神装图鉴界面
function HeroController:openHeroClothesLustratWindow(status)
    if status == true then
        if not self.hero_clothes_lustrat_view then
            self.hero_clothes_lustrat_view = HeroClothesLustratWindow.New()
        end
        self.hero_clothes_lustrat_view:open()
    else
        if self.hero_clothes_lustrat_view then 
            self.hero_clothes_lustrat_view:close()
            self.hero_clothes_lustrat_view = nil
        end
    end
end


--打开神装预览 
function HeroController:openHolyequipmentTotalAttrPanel(status, data, holyequip_suit_data)
    if status == true then
        if not self.holyequipment_total_attr_panel then
            self.holyequipment_total_attr_panel = HolyequipmentTotalAttrPanel.New()
        end
        self.holyequipment_total_attr_panel:open(data, holyequip_suit_data)
    else
        if self.holyequipment_total_attr_panel then 
            self.holyequipment_total_attr_panel:close()
            self.holyequipment_total_attr_panel = nil
        end
    end
end

--打开神装方案 
function HeroController:openHolyequipmentPlanPanel(status, data)
    if status == true then
        if not self.holyequipment_plan_panel then
            self.holyequipment_plan_panel = HolyequipmentPlanPanel.New()
        end
        self.holyequipment_plan_panel:open(data)
    else
        if self.holyequipment_plan_panel then 
            self.holyequipment_plan_panel:close()
            self.holyequipment_plan_panel = nil
        end

    end
end

--打开神装穿戴界面
function HeroController:openHeroHolyEquipClothPanel(bool,pos,partner_id,data,holy_data,enter_type,hero_vo,equip_list)
    if bool == true then
        if not self.equip_cloth_panel then 
            self.equip_cloth_panel = HeroHolyEquipClothPanel.New(pos,partner_id,data,holy_data,enter_type,hero_vo,equip_list)
        end
        if self.equip_cloth_panel and self.equip_cloth_panel:isOpen() == false then
            self.equip_cloth_panel:open()
        end
    else 
        if self.equip_cloth_panel then 
            self.equip_cloth_panel:close()
            self.equip_cloth_panel = nil
        end
    end
end


--保存神装套装提示
function HeroController:openHolyequipmentSaveTips(status, holy_data)
    if status == true then
        if not self.holyequipment_save_tips then
            self.holyequipment_save_tips = HolyequipmentSaveTips.New()
        end
        if self.holyequipment_save_tips:isOpen() == false then
            self.holyequipment_save_tips:open(holy_data)
        end
    else
        if self.holyequipment_save_tips then
            self.holyequipment_save_tips:close()
            self.holyequipment_save_tips = nil
        end
    end
end

--装配神装套装提示
--@holy_data：待装配套装数据 {id, name, hero_vo, item_list}
function HeroController:openHolyequipmentWearTips(status, holy_data)
    if status == true then
        if not self.holyequipment_wear_tips then
            self.holyequipment_wear_tips = HolyequipmentWearTips.New()
        end
        if self.holyequipment_wear_tips:isOpen() == false then
            self.holyequipment_wear_tips:open(holy_data)
        end
    else
        if self.holyequipment_wear_tips then
            self.holyequipment_wear_tips:close()
            self.holyequipment_wear_tips = nil
        end
    end
end

--保存神装套装方案提示
--@hero_vo：当前宝可梦数据
--@plan_data：所有神装套装数据
function HeroController:openHolyequipmentChooseTips(status, hero_vo, plan_data)
    if status == true then
        if not self.holyequipment_choose_tips then
            self.holyequipment_choose_tips = HolyequipmentChooseTips.New()
        end
        if self.holyequipment_choose_tips:isOpen() == false then
            self.holyequipment_choose_tips:open(hero_vo, plan_data)
        end
    else
        if self.holyequipment_choose_tips then
            self.holyequipment_choose_tips:close()
            self.holyequipment_choose_tips = nil
        end
    end
end

--打开皮肤界面
function HeroController:openHeroSkinWindow(status, bid)
    if status == true then
        if not self.hero_skin_window then
            self.hero_skin_window = HeroSkinWindow.New()
        end
        self.hero_skin_window:open(bid)
    else
        if self.hero_skin_window then 
            self.hero_skin_window:close()
            self.hero_skin_window = nil
        end
    end
end

--desc:----打开皮肤tips
--@bool:打开与关闭
--@data:装备数据
--@open_type:装备状态，0.其他状态，1: 背包中 3:伙伴身上 具体查看 PartnerConst.EqmTips
--@partner_id:穿戴在伙伴身上就有伙伴id，其他可不填或填0
--@return 
function HeroController:openHeroSkinTipsPanel(status, data, open_type, partner)
    if status == true then
        if not self.hero_skin_tips_panel then
            self.hero_skin_tips_panel = HeroSkinTipsPanel.New()
        end
        self.hero_skin_tips_panel:open(data, open_type, partner)
    else
        if self.hero_skin_tips_panel then 
            self.hero_skin_tips_panel:close()
            self.hero_skin_tips_panel = nil
        end
    end
end

--打开共鸣页面
function HeroController:openHeroResonateWindow(status, setting)
    if status == true then
        if not self.model:checkResonateIsOpen() then
            return
        end

        if not self.hero_resonate_window then
            self.hero_resonate_window = HeroResonateWindow.New()
        end
        self.hero_resonate_window:open(setting)
    else
        if self.hero_resonate_window then 
            self.hero_resonate_window:close()
            self.hero_resonate_window = nil
        end
    end
end
--打开提炼界面
function HeroController:openHeroResonateExtractPanel(status, setting)
    if status == true then
        if not self.model:checkResonateIsOpen() then
            return
        end

        if not self.hero_resonate_extract_panel then
            self.hero_resonate_extract_panel = HeroResonateExtractPanel.New()
        end
        self.hero_resonate_extract_panel:open(setting)
    else
        if self.hero_resonate_extract_panel then 
            self.hero_resonate_extract_panel:close()
            self.hero_resonate_extract_panel = nil
        end
    end
end
--打开选择天赋技能界面
function HeroController:openHeroResonateSelectTalentSkillPanel(status, setting)
    if status == true then
        if not self.hero_resonate_select_talent_skill_panel then
            self.hero_resonate_select_talent_skill_panel = HeroResonateSelectTalentSkillPanel.New()
        end
        self.hero_resonate_select_talent_skill_panel:open(setting)
    else
        if self.hero_resonate_select_talent_skill_panel then 
            self.hero_resonate_select_talent_skill_panel:close()
            self.hero_resonate_select_talent_skill_panel = nil
        end
    end
end

--打开提炼注入经验界面
function HeroController:openHeroResonateSelectExpPanel(status, setting)
    if status == true then
        if not self.model:checkResonateIsOpen() then
            return
        end
        if not self.hero_resonate_select_exp_panel then
            self.hero_resonate_select_exp_panel = HeroResonateSelectExpPanel.New()
        end
        self.hero_resonate_select_exp_panel:open(setting)
    else
        if self.hero_resonate_select_exp_panel then 
            self.hero_resonate_select_exp_panel:close()
            self.hero_resonate_select_exp_panel = nil
        end
    end
end

--打开共鸣水晶卸下宝可梦
function HeroController:openHeroResonatePutDownPanel(status, setting)
    if status == true then
        if not self.model:checkResonateIsOpen() then
            return
        end
        if not self.hero_resonate_put_down_panel then
            self.hero_resonate_put_down_panel = HeroResonatePutDownPanel.New()
        end
        self.hero_resonate_put_down_panel:open(setting)
    else
        if self.hero_resonate_put_down_panel then 
            self.hero_resonate_put_down_panel:close()
            self.hero_resonate_put_down_panel = nil
        end
    end
end
--共鸣水晶放入宝可梦成功
function HeroController:openHeroResonatePutResultPanel(status, setting)
    if status == true then
        if not self.hero_resonate_put_result_panel then
            self.hero_resonate_put_result_panel = HeroResonatePutResultPanel.New()
        end
        self.hero_resonate_put_result_panel:open(setting)
    else
        if self.hero_resonate_put_result_panel then 
            self.hero_resonate_put_result_panel:close()
            self.hero_resonate_put_result_panel = nil
        end
    end
end
--共鸣水晶升级
function HeroController:openHeroResonateComfirmLevPanel(status, setting)
    if status == true then
        if not self.hero_resonate_comfirm_lev_panel then
            self.hero_resonate_comfirm_lev_panel = HeroResonateComfirmLevPanel.New()
        end
        self.hero_resonate_comfirm_lev_panel:open(setting)
    else
        if self.hero_resonate_comfirm_lev_panel then 
            self.hero_resonate_comfirm_lev_panel:close()
            self.hero_resonate_comfirm_lev_panel = nil
        end
    end
end

--重生确定
function HeroController:openHeroResetComfirmPanel(status, setting)
    if status == true then
        if not self.hero_reset_comfirm_panel then
            self.hero_reset_comfirm_panel = HeroResetComfirmPanel.New()
        end
        self.hero_reset_comfirm_panel:open(setting)
    else
        if self.hero_reset_comfirm_panel then 
            self.hero_reset_comfirm_panel:close()
            self.hero_reset_comfirm_panel = nil
        end
    end
end




----------------@ 引导需要
-- 宝可梦背包
function HeroController:getHeroBagRoot(  )
    if self.hero_bag_window ~= nil then
        return self.hero_bag_window.root_wnd
    end
end
-- 宝可梦信息界面
function HeroController:getHeroMianInfoRoot(  )
    if self.hero_main_info_window ~= nil then
        return self.hero_main_info_window.root_wnd
    end
end
-- 布阵
function HeroController:getHeroFormRoot(  )
    if self.form_window ~= nil then
        return self.form_window.root_wnd
    end
end
-- 宝可梦出战
function HeroController:getHeroGoFightRoot(  )
    if self.form_go_fight_panel ~= nil then
        return self.form_go_fight_panel.root_wnd
    end
end

-- 宝可梦神装穿戴
function HeroController:getHeroHolyEquipClothPanelRoot(  )
    if self.equip_cloth_panel ~= nil then
        return self.equip_cloth_panel.root_wnd
    end
end

-- 共鸣界面
function HeroController:getHeroResonateWindowRoot(  )
    if self.hero_resonate_window ~= nil then
        return self.hero_resonate_window.root_wnd
    end
end



-----------------------公共方法处理------------------
--播放宝可梦音效，保证音效不会因为切出宝可梦信息界面而中断
function HeroController:onPlayHeroVoice(vocie_res, time, audio_type)
    if audio_type == nil or audio_type == "" then
        audio_type = AudioManager.AUDIO_TYPE.DUBBING
    end
    --默认4秒
    local time = time or 4
    if time == 0 then
        time = 4
    end
    --补充一秒时差 
    time = time + 1
    if self.voice_time_ticket == nil then
        --减少音量
        local volume = SysEnv:getInstance():getNum(SysEnv.keys.music_volume, 100)
        volume = volume - 60
        AudioManager:getInstance():setMusicVolume(volume/100)
    else
        GlobalTimeTicket:getInstance():remove(self.voice_time_ticket)
        self.voice_time_ticket = nil
    end

    if self.hero_music ~= nil then
        AudioManager:getInstance():removeEffectByData(self.hero_music)
    end
    self.hero_music = AudioManager:getInstance():playEffect(audio_type, vocie_res, false)

    self.voice_time_ticket = GlobalTimeTicket:getInstance():add(function() 
        --还原音量
        local volume = SysEnv:getInstance():getNum(SysEnv.keys.music_volume, 100)
        AudioManager:getInstance():setMusicVolume(volume/100)
        self.voice_time_ticket = nil
    end, time, 1) 

end
-----------------------------------------------

-----------------------重生方法处理------------------
function HeroController:showSingleRowItemList(item_scrollview, item_list, data_list, setting)
    if not item_scrollview then 
        -- print("对象 item_scrollview 不能为空")
        return
    end
    if not data_list then 
        -- print("data_list不能为空!")
        return
    end
    local item_list = item_list

    if item_list then
        --隐藏物品
        for i,v in pairs(item_list) do
            if v.DeleteMe then
                v:DeleteMe()
                v = nil
            end
        end
        item_list = {}
    end

    if item_list == nil then 
        item_list = {}
    end

    if  #data_list == 0 then
        return 
    end
    --道具列表
    local setting = setting or {}
    local scale = setting.scale or 1
    local start_x = setting.start_x or 5
    local space_x = setting.space_x or 5
    local max_count = setting.max_count
    local item_width = setting.item_width or BackPackItem.Width
    local lock = setting.lock or false
    local is_show_action = setting.is_show_action or false
    --点击返回回调函数
    local is_tip = setting.is_tip
    local callback = setting.callback or false

    local item_count = #data_list
    item_width = item_width * scale

    local total_width =  start_x * 2 + item_width * item_count + space_x * (item_count - 1)
    local item_scrollview_size = item_scrollview:getContentSize()
    local max_width = math.max(item_scrollview_size.width, total_width)
    item_scrollview:setInnerContainerSize(cc.size(max_width, item_scrollview_size.height))
    if max_count and item_count < max_count then
        item_scrollview:setTouchEnabled(false)
        if setting.is_center then
            start_x = (item_scrollview_size.width - total_width) * 0.5
            if start_x < 0 then
                start_x = 0
            end
        end
    else
        item_scrollview:setTouchEnabled(true)
    end
    item_scrollview:stopAllActions()

    local function _setItemData(item, v, i)
        item:setVisible(true)
        local _x = start_x + (i - 1) * (item_width + space_x)
        item:setPosition(_x, item_scrollview_size.height * 0.5)
        item:setBaseData(v[1], v[2], true)
        item:showOrderWarLock(lock)
        if callback then
            item:addCallBack(function()
                callback()
            end)
        end
        if v[3] then
            item:setGoodsName(v[3],nil,24,nil)
        end
        item:setDefaultTip(is_tip)
        if setting.show_effect_id then
            item:showItemEffect(true, setting.show_effect_id, PlayerAction.action_1, true, 1.1)
        else
            item:showItemEffect(false)
        end
    end
    local item = nil
    local size = #item_list 
    
    for i, v in ipairs(data_list) do
        local dealey = i - size
        if dealey <= 0 then
            dealey = 1
        end
        local time = 0
        if is_show_action then
            time = 0.1 * dealey
        else
            time = dealey / display.DEFAULT_FPS
        end
        delayRun(item_scrollview, time, function ()
            if not item_list[i] then
                if v.show_type ~= nil and v.show_type == MainuiConst.item_exhibition_type.partner_type then
                    item = HeroExhibitionItem.new(scale, true)
                    item:addCallBack(function() 
                        -- if v.rid and v.srv_id then
                        --     HeroController:getInstance():openHeroTipsPanel(true, v)
                        -- else
                        --     HeroController:getInstance():openHeroTipsPanelByBid(v.bid)
                        -- end
                    end)
                    local _x = start_x + (i - 1) * (item_width + space_x)
                    item:setPosition(_x, item_scrollview_size.height * 0.5)
                    item:setAnchorPoint(cc.p(0, 0.5))
                    item:setData(v)
                    item_scrollview:addChild(item)
                    item_list[i] = item
                else
                    item = BackPackItem.new(true, true)
                    item:setAnchorPoint(0, 0.5)
                    item:setScale(scale)
                    item:setSwallowTouches(false)
                    item_scrollview:addChild(item)
                    item_list[i] = item
                    _setItemData(item, v, i)
                    if is_show_action then
                        item:setScale(scale * 1.3)
                        item:runAction(cc.ScaleTo:create(0.1, scale))
                    end
                end
            end
        end)
    end
    return item_list
end
----------------------------------------------------------------------------

function HeroController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end