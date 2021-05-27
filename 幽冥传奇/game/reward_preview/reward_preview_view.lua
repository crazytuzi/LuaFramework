------------------------------------------------------------
-- 奖励预览View
------------------------------------------------------------
RewardPreviewView = RewardPreviewView or BaseClass(BaseView)

function RewardPreviewView:__init()
	self.view_name = ViewName.RewardPreview
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = "res/xui/reward_preview.png"   
	self.config_tab = {
		{"reward_preview_ui_cfg", 1, {0}},
	}

end

function RewardPreviewView:__delete()
end

--释放回调
function RewardPreviewView:ReleaseCallBack()
    if self.reward_scroll_list then
        self.reward_scroll_list:DeleteMe()
        self.reward_scroll_list = nil
    end
end

function RewardPreviewView:LoadCallBack(index, loaded_times)
    XUI.AddClickEventListener(self.node_t_list.btn_help.node, BindTool.Bind(self.OnClickTips, self))
	self:CreateRewardListView()
end

--打开帮助回调
function RewardPreviewView:OnClickTips()
    local act_id = ActivityData.Instance:GetActivityID()
    DescTip.Instance:SetContent(Language.RewardPreview.TipContent[act_id], Language.RewardPreview.TipTilte)
end

--打开回调
function RewardPreviewView:OpenCallBack()
	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
end

--关闭回调
function RewardPreviewView:CloseCallBack(is_all)
    if nil ~= self.scene_change then
        GlobalEventSystem:UnBind(self.scene_change)
        self.scene_change = nil
    end
end

--显示指数回调
function RewardPreviewView:ShowIndexCallBack(index)
    local act_id = ActivityData.Instance:GetActivityID()
    local data = RewardPreviewData.GetPreViewList(act_id)
    self.reward_scroll_list:SetDataList(data)
end

----------------------------------------
-- 滚动控件
function RewardPreviewView:CreateRewardListView()
    if nil == self.reward_scroll_list then
        local ph = self.ph_list.ph_list_view
        self.reward_scroll_list = ListView.New()
        self.reward_scroll_list:Create( ph.x, ph.y, ph.w, ph.h, nil, self.RewardPreviewRender, nil, nil, self.ph_list.ph_list_cell)
        self.node_t_list.layout_reward.node:addChild(self.reward_scroll_list:GetView(), 100)
        self.reward_scroll_list:SetJumpDirection(ListView.Top)
        self.reward_scroll_list:SetMargin(2) --首尾留空
    end
end

function RewardPreviewView:OnSceneChangeComplete()
    if nil ~= self.scene_change then
        GlobalEventSystem:UnBind(self.scene_change)
        self.scene_change = nil
    end
    ViewManager.Instance:CloseViewByDef(ViewDef.RewardPreview)
end

----------奖励预览----------
RewardPreviewView.RewardPreviewRender = BaseClass(BaseRender)
local RewardPreviewRender = RewardPreviewView.RewardPreviewRender

function RewardPreviewRender:__init()
    -- 配置则更换图片,未配置则显示名次
	self.cfg = {
        [DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS] = {[1] = "ranking4", [2] = "ranking5", [3] = "ranking2", [4] = "ranking3",},
        [DAILY_ACTIVITY_TYPE.ZHEN_YING] = {[11] = "ranking2"},
        [DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS] = {[11] = "ranking2", [12] = "ranking3",},
    }
end

function RewardPreviewRender:__delete()
    if self.awards_list then
        self.awards_list:DeleteMe()
        self.awards_list = nil
    end
    if self.ranking then
        self.ranking:DeleteMe()
        self.ranking = nil
    end
end

function RewardPreviewRender:CreateChild()
	BaseRender.CreateChild(self)
--  第几名
    if nil == self.ranking then
        local ph = self.ph_list.ph_ranking
        self.ranking = NumberBar.New()
        self.ranking:SetRootPath(ResPath.GetCommon("num_100_"))
        self.ranking:SetPosition(ph.x, ph.y)
        self.ranking:SetGravity(NumberBarGravity.Center)
        self.view:addChild(self.ranking:GetView(), ph.w, ph.h)
    end
    if nil == self.awards_list then
        local ph = self.ph_list.ph_cell_grid
        local ph_item = self.ph_list.ph_awrad
        self.awards_list = GridScroll.New()
        self.awards_list:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h - 5, self.RewardPreviewCell, ScrollDir.Horizontal, false, ph_item)
        self.view:addChild(self.awards_list:GetView(), 100)
    end
end

function RewardPreviewRender:OnFlush()
	if nil == self.data then
		return
	end
    local act_id = ActivityData.Instance:GetActivityID()
    -- 设置名次
    if self.cfg[act_id][self.index] then
        local path = ResPath.GetRewardPreview(self.cfg[act_id][self.index])
        self.node_tree["ranking1"].node:loadTexture(path)
        self.ranking:GetView():setVisible(false)
    else
        local path = ResPath.GetRewardPreview("ranking")
        self.node_tree["ranking1"].node:loadTexture(path)
        self.ranking:SetNumber(self:GetIndex())
        self.ranking:GetView():setVisible(true)
    end

    local data_list ={}
    for k, v in ipairs(self.data) do
        local item_config = ItemData.Instance:GetItemConfig(v.id)
        local item_data = ItemData.FormatItemData(v)
        table.insert(data_list,item_data)
    end
    self.awards_list:SetDataList(data_list)  
end

function RewardPreviewRender:CreateSelectEffect()
	return
end

-----------------------------------------------------------------
RewardPreviewRender.RewardPreviewCell = RewardPreviewRender.RewardPreviewCell or BaseClass(BaseCell)
local RewardPreviewCell = RewardPreviewRender.RewardPreviewCell

function RewardPreviewCell:__delete()
    if self.item_cell then
        self.item_cell:DeleteMe()
        self.item_cell = nil
    end
end

function RewardPreviewCell:OnFlush()
   BaseCell.OnFlush(self)
	if nil == self.data then
		return
	end

    self:GetView():setScale(0.8)

	self:SetData(self.data)

end

----------end----------