---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/19 14:36:03
-- @description: 圣夜奇境bossitem
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_isnert = table.insert
local _string_format = string.format

HolynightBossItem = class("HolynightBossItem",function()
    return ccui.Layout:create()
end)

function HolynightBossItem:ctor()
    self:configUI()
    self:registerEvent()
end

function HolynightBossItem:configUI()
    self.size = cc.size(617, 142)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("monopoly/holynight_boss_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.container:getChildByName("award_title"):setString(TI18N("击杀奖励"))

    self.btn_challenge = self.container:getChildByName("btn_challenge")
    local btn_size = self.btn_challenge:getContentSize()
    self.btn_challenge_label = createRichLabel(26, cc.c4b(37, 85, 5, 255), cc.p(0.5, 0.5), cc.p(btn_size.width*0.5, btn_size.height*0.5))
    self.btn_challenge:addChild(self.btn_challenge_label)
    local gold_cfg = Config.MonopolyMapsData.data_const["monopoly_gold_id"]
    if gold_cfg then
        local gold_item_cfg = Config.ItemData.data_get_data(gold_cfg.val)
        if gold_item_cfg then
            self.gold_item_res = PathTool.getItemRes(gold_item_cfg.icon)
            self.btn_challenge_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /> 1 挑战"), self.gold_item_res))
        end
    end
    
    self.pass_sp = self.container:getChildByName("pass_sp")
    self.pos_node = self.container:getChildByName("pos_node")
    self.name_txt = self.container:getChildByName("name_txt")
    self.lock_txt = self.container:getChildByName("lock_txt")
    self.lock_txt:setVisible(false)
    self.pass_txt = self.container:getChildByName("pass_txt")
    self.pass_txt:setString(TI18N("已击杀"))
    self.zhuiji_sp = self.container:getChildByName("zhuiji_sp")

    -- 进度
    self.progress = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("monopoly", "monopolyboss_1004", false, "monopolyboss"), 110, 105, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.progress:setReverseProgress(true)
    self.progress:setPosition(70, 86)
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.container:addChild(self.progress)
    -- 进度(红色)
    self.progress_2 = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("monopoly", "monopolyboss_1013", false, "monopolyboss"), 110, 105, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.progress_2:setReverseProgress(true)
    self.progress_2:setPosition(70, 86)
    self.progress_2:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.progress_2:setVisible(false)
    self.container:addChild(self.progress_2)

    local item_list = self.container:getChildByName("item_list")
    local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 0,
        space_x = 5,
        start_y = 0,
        space_y = 0,
        item_width = BackPackItem.Width*0.7,
        item_height = BackPackItem.Height*0.7,
        row = 1,
        col = 1,
        scale = 0.7,
    }
    self.goods_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.goods_scrollview:setSwallowTouches(false)
end

function HolynightBossItem:registerEvent()
    registerButtonEventListener(self.btn_challenge, handler(self, self.onClickChallengeBtn), true)
end

function HolynightBossItem:onClickChallengeBtn(  )
    if self.data and (self.data.state == 2 or self.data.state == 4)  then
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Monopoly_Boss, {step_id = self.data.id, boss_id = self.data.boss_id})
    end
end

function HolynightBossItem:setData(data)
    if not data then return end

    self.data = data

    -- 英雄头像和名称
    self.name_txt:setString(data.boss_name or "")
    if not self.hero_icon then
        self.hero_icon = PlayerHead.new(PlayerHead.type.circle)
        self.pos_node:addChild(self.hero_icon)
    end
    self.hero_icon:setHeadRes(data.head_id)

    -- 进度
    local left_hp = data.hp or 0
    local max_hp = data.max_hp or 1
    local percent = left_hp/max_hp*100
    self.progress:setPercentage(percent)
    self.progress_2:setPercentage(percent)
    
    -- 击杀奖励
    local award_list = {}
    for k,v in pairs(data.reward) do
        local bid = v[1]
        local num = v[2]
        local vo = deepCopy(Config.ItemData.data_get_data(bid))
        if vo then
            vo.quantity = num
            _table_isnert(award_list,vo)
        end
    end
    self.goods_scrollview:setData(award_list)
    self.goods_scrollview:addEndCallBack(
        function()
            local list = self.goods_scrollview:getItemList()
            for k, v in pairs(list) do
                v:setDefaultTip(true)
            end
        end
    )

    self.lock_txt:setVisible(data.state == 1)
    self.btn_challenge:setVisible(data.state == 2 or data.state == 4)
    self.pass_txt:setVisible(data.state == 3)
    self.pass_sp:setVisible(data.state == 3)
    self.progress:setVisible(data.state ~= 4)
    self.progress_2:setVisible(data.state == 4)
    self.zhuiji_sp:setVisible(data.state == 4)
    if data.state == 1 then -- 未解锁
        self.progress:setPercentage(100)
        self.lock_txt:setString(_string_format(TI18N("%d探索值解锁"), data.develop))
    elseif data.state == 2 then -- 可挑战
        self.btn_challenge:loadTexture(PathTool.getResFrame("common", "common_1098"), LOADTEXT_TYPE_PLIST)
        self.btn_challenge:setContentSize(cc.size(141, 54))
        self.btn_challenge_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#255505> 1 挑战</div>"), self.gold_item_res))
    elseif data.state == 3 then -- 已击败
        
    elseif data.state == 4 then -- 可追击
        self.progress_2:setPercentage(100)
        self.btn_challenge:loadTexture(PathTool.getResFrame("common", "common_1027"), LOADTEXT_TYPE_PLIST)
        self.btn_challenge_label:setString(_string_format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#712804> 1 挑战</div>"), self.gold_item_res))
        self.btn_challenge:setContentSize(cc.size(141, 54))
    end
end

function HolynightBossItem:DeleteMe()
    if self.goods_scrollview then
        self.goods_scrollview:DeleteMe()
        self.goods_scrollview = nil
    end
    if self.hero_icon then
        self.hero_icon:DeleteMe()
        self.hero_icon = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end