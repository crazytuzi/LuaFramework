---
--- Created by  Administrator
--- DateTime: 2019/5/10 15:41
---
ArenaAwardPanel = ArenaAwardPanel or class("ArenaAwardPanel", WindowPanel)
local this = ArenaAwardPanel

function ArenaAwardPanel:ctor(parent_node, parent_panel)
    self.abName = "arena";
    self.image_ab = "arena_image";
    self.assetName = "ArenaAwardPanel"
    self.layer = "UI"
    self.events = {}
    self.btnSelects = {}
    self.btnTexSelects = {}
    self.items = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 5
    self.itemType = 0
    self.model = ArenaModel:GetInstance()
end

function ArenaAwardPanel:dctor()
    self.model:RemoveTabListener(self.events)
    for i, v in pairs(self.items) do
        v:destroy()
    end
    self.items = {}	
	
	self.btnSelects = nil
    self.btnTexSelects = nil
end

function ArenaAwardPanel:Open()
    ArenaAwardPanel.super.Open(self)
end


function ArenaAwardPanel:LoadCallBack()
    self.nodes = {
        "ArenaAwardItem","btns/tupoBtn","btns/dailyBtn","btns/bigGodBtn","ScrollView/Viewport/itemContent",
        "btns/dailyBtn/dailyBtnSelect","btns/tupoBtn/tupoBtnSelect","btns/bigGodBtn/bigGodBtnSelect","des",
        "btns/tupoBtn/tupoBtnText","btns/dailyBtn/dailyBtnText","btns/bigGodBtn/bigGodBtnText",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.tupoBtnText = GetText(self.tupoBtnText)
    self.dailyBtnText = GetText(self.dailyBtnText)
    self.bigGodBtnText = GetText(self.bigGodBtnText)
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("arena_image", "arena_title4")
    self.btnSelects[1] = self.tupoBtnSelect
    self.btnSelects[2] = self.dailyBtnSelect
    self.btnSelects[3] = self.bigGodBtnSelect

    self.btnTexSelects[1] = self.tupoBtnText
    self.btnTexSelects[2] = self.dailyBtnText
    self.btnTexSelects[3] = self.bigGodBtnText


  --  self:ClickBtn(1)
    ArenaController:GetInstance():RequstHighestRank()
end



function ArenaAwardPanel:InitUI()

end

function ArenaAwardPanel:AddEvent()
    
    local function call_back()  --突破
        self:ClickBtn(1)
    end
    AddClickEvent(self.tupoBtn.gameObject,call_back)

    local function call_back()  --日常
        self:ClickBtn(2)
    end
    AddClickEvent(self.dailyBtn.gameObject,call_back)

    local function call_back()  --大神
        self:ClickBtn(3)
    end
    AddClickEvent(self.bigGodBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaHighestRank, handler(self, self.ArenaHighestRank))
    self.events[#self.events + 1] = self.model:AddListener(ArenaEvent.ArenaLqHighestRank, handler(self, self.ArenaLqHighestRank))
    

end

function ArenaAwardPanel:ClickBtn(index)
    for i = 1, #self.btnSelects do
        if i == index then
            SetVisible(self.btnSelects[i],true)
            SetColor(self.btnTexSelects[i], 133, 132, 176, 255)
        else
            SetVisible(self.btnSelects[i],false)
            SetColor(self.btnTexSelects[i], 255, 255, 255, 255)
        end
    end
    self:UpdateItems(index)

end

function ArenaAwardPanel:UpdateItems(index)
    local tab
    if index == 1 then --
        tab = Config.db_arena_high_rank
        self.des.text = "Tip: Climbing up to get great rewards!"
		table.sort(tab,function(a,b)
				if self.model:GetRewardState(a) ~= self.model:GetRewardState(b) then
					return self.model:GetRewardState(a) > self.model:GetRewardState(b)
				else
					return a.id < b.id
				end
			
		end)
		
    elseif index == 2 then
        tab = Config.db_arena_rank
        self.des.text = "Tips: Abundant rewards give out at 22:00. Claim and enjoy!"
    elseif index == 3 then
        self.des.text = "Tips: Ace players enjoy bonuses. Abundant rewards give out at 22:00!"
        tab = Config.db_arena_top_rank
    end
    self.itemType = index
    self.items = self.items or {}
    for i = 1, #tab do
        local role = self.items[i]
        if not role then
            role = ArenaAwardItem(self.ArenaAwardItem.gameObject,self.itemContent,"UI")
            self.items[i] = role
        else
            role:SetVisible(true)
        end
        role:SetData(tab[i],index,i)
    end
    for i = #tab + 1,#self.items do
        local Item = self.items[i]
        Item:SetVisible(false)
    end
end

function ArenaAwardPanel:ArenaHighestRank(data)
    self:ClickBtn(1)
end

function ArenaAwardPanel:ArenaLqHighestRank(data)
    --local id = data.id
    --if self.itemType == 1 then
        --for i = 1, #self.items do
            --if self.items[i].data.id == id then
                --self.items[i]:SetLqState()
                --break
            --end
        --end
    --end
	self:UpdateItems(1)
end

function ArenaAwardPanel:SetDes()
    
end