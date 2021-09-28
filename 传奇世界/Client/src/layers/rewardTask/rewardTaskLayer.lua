-- 悬赏任务
local rewardTaskLayer = class("rewardTaskLayer", function() return cc.Layer:create() end);

function rewardTaskLayer:ctor(params)
    -- 初始值
    self.m_selectIndex = 0;
    self.m_centerBg = nil;
    self.m_curLayer = nil;

    local idx = params or 1;
    -- function createBgSprite(parent, tileName, tileNameEx, quick_Type, endFunc)
    local bg = createBgSprite(self, nil, nil, nil, function()
            self:Clear();
        end);
    
    local centerBg = cc.Node:create()
    centerBg:setPosition(cc.p(15, 23))
    centerBg:setContentSize(cc.size(930, 535))
    centerBg:setAnchorPoint(cc.p(0, 0))
    bg:addChild(centerBg)
    self.m_centerBg = centerBg

    --self.m_centerBg = createSprite(bg, "res/common/bg/bg-6.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2 - 30));

    -- 创建底部选项按钮
    local menuFunc = function(tag)
        if (tag == 0 or self.m_selectIndex == tag or G_ROLE_MAIN == nil) then
            return;
        end

        self.m_selectIndex = tag;

        self.m_centerBg:removeAllChildren();

        if self.m_selectIndex == 1 then
            self.m_curLayer = require("src/layers/rewardTask/rewardTaskAcceptViewLayer").new();
        else
            self.m_curLayer = require("src/layers/rewardTask/rewardTaskMyViewLayer").new();
            require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(5);
        end

        if self.m_curLayer ~= nil then
            self.m_centerBg:addChild(self.m_curLayer, 125);
        end
    end

    local tab_addBlood = game.getStrByKey("taskRewardTitle")
	local tab_pickupSet = game.getStrByKey("taskMyReward")
	local tabs = {}
	tabs[#tabs+1] = tab_addBlood
	tabs[#tabs+1] = tab_pickupSet
	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
            menuFunc(tag)
            local title_label = bg:getChildByTag(12580)
            title_label:setString(tabs[tag])
		end,
		selected = 1,
	})
	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})

    SwallowTouches(self);
    G_TUTO_NODE:setTouchNode(TabControl:tabAtIdx(2), TOUCH_REWARDTASK_MY)
    ---------------------------------------------------------------------------------
    -- 注册回调
    DATA_Mission:setCallback( "rewardTaskSelfLayer" , function(idx)
        if idx == 6 and self.m_curLayer ~= nil and self.m_curLayer.is_rewardTaskAcceptViewLayer then -- id说明:直接从缓存加载可以接取的悬赏任务
            self.m_curLayer:LoadCacheData()
        end

        if idx == 5 then  -- idx说明:5.代表关闭窗口
            self:Clear();
            local cb = function() 
				TextureCache:removeUnusedTextures()
			end
			removeFromParent(self, cb);
            return;
        end

        --刷新我的悬赏界面tip
        if idx == 4 and getRunScene():getChildByTag(require("src/config/CommDef").TAG_REWARD_TASK_DIALOG) then
            getRunScene():getChildByTag(require("src/config/CommDef").TAG_REWARD_TASK_DIALOG):RefreshData()
        end

        local bNeedRefresh = false
        if idx == 4 and self.m_selectIndex == 2 then    -- idx说明:4.代表刷新我的悬赏任务
            bNeedRefresh = true
        elseif idx == 1 and self.m_selectIndex == 1 then    -- idx说明:1.代表刷新可接取的悬赏任务
            bNeedRefresh = true
        end

        if bNeedRefresh then
            if self.m_curLayer ~= nil then
                self.m_curLayer:RefreshData()
            end
        end
    end )

    startTimerActionEx(self, 1.0, true, function(delTime)
        -- 悬赏任务全局定时器 [1s 执行一次]
        DATA_Mission:RewardTaskCountdown();
    end)

    G_TUTO_NODE:setShowNode(self, SHOW_REWARDTASK)
end

function rewardTaskLayer:Clear()
    DATA_Mission:setCallback("rewardTaskSelfLayer", nil);
end

return rewardTaskLayer;
