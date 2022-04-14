RankRightItem = RankRightItem or class("RankRightItem",BaseCloneItem)


function RankRightItem:ctor(obj,parent_node,layer)
    RankRightItem.super.Load(self)
    self.model = RankModel:GetInstance()
end
function RankRightItem:dctor()
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
end

function RankRightItem:LoadCallBack()
    self.nodes =
    {
        "nameObj/name",
        "nameObj/nameTitle",
        "rankObj/rankTex",
        "unionTex",
        "titleTex",
        "levelTex",
        "powerTex",
        "vipTex",
        "click",
        "bg",
        "rankImg",
        "rankObj",
		"levelParent"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.nameTex = GetText(self.name)
    self.rankTex = GetText(self.rankTex)
    self.vipTex = GetText(self.vipTex)
   -- self.powerTex = GetText(self.powerTex)
    --self.titleTex = GetText(self.titleTex)
    self.nameTitleTex = GetText(self.nameTitle)
    self.unionTex = GetText(self.unionTex)
    self.levelTex = GetText(self.levelTex)
    self.rankImg = GetImage(self.rankImg)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:AddEvent()
end

function RankRightItem:SetData(rankType,data)
    self.data = data
    self.rankType = rankType
    self:InitUI()
end

function RankRightItem:InitUI()
    local roleBase = self.data.base
    self.nameTex.text = roleBase.name
    self.rankTex.text = self.data.rank
    self.vipTex.text = "V"..roleBase.viplv
    --self.levelTex.text = roleBase.level

    self:SetType()
    self:SetBg()
    self:SetTitle()
end
function RankRightItem:SetType()
    local roleBase = self.data.base
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
    --print2(roleBase.gname)
    if self.rankType == 1001 then  --等级榜
        self.levelTex.text = ""

		self.lvItem = LevelShowItem(self.levelParent)
		self.lvItem:SetData(19,roleBase.level,"CF4526")
		
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname

    elseif self.rankType == 1002 then --战力榜
        self.levelTex.text = self.data.sort
       -- local wakeKey
        local career = self.data.base.career
        local wake = self.data.base.wake
        local db = Config.db_wake[career.."@"..wake]

        local des = self.data.base.wake..ConfigLanguage.Wake.Wake.."·"..db.name
        self.unionTex.text = des
        --self.unionTex.text = string.format("%s次觉醒",self.data.base.wake)
    elseif self.rankType == 1003 then

        local cfg = self.model:GetMountNumByID(self.data.sort)
        self.levelTex.text = string.format("T%sS%s",cfg.order,cfg.level)
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname

    elseif self.rankType == 1004 then
        local cfg = self.model:GetOffhandNumByID(self.data.sort)
        self.levelTex.text = string.format("T%sS%s",cfg.order,cfg.level)
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname
    elseif self.rankType == 1005 then
        self.levelTex.text = self.data.sort
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname
    elseif self.rankType == 1006 then
        dump(self.data)
        self.levelTex.text = self.data.sort
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname
    elseif self.rankType == 1007 then
        self.levelTex.text = self.data.sort
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname
    elseif self.rankType == 1008 then
       -- self.levelTex.text = self.data.sort
        self.levelTex.text = string.format("%s/min",GetShowNumber(self.data.sort))
        if roleBase.guild == nil or roleBase.gname == "" then
            self.unionTex.text = "No guild yet"
            return
        end
        self.unionTex.text = roleBase.gname
    end
end


function RankRightItem:AddEvent()
    function call_back()         --查看信息RequireConfig
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.name)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.click.gameObject,call_back)
end

function RankRightItem:SetBg()
    if self.data.rank % 2 ~= 0 then
        SetVisible(self.bg,false)
    end

    if self.data.rank <= 3 then
        SetVisible(self.rankObj,false)
        SetVisible(self.rankImg.gameObject,true)
        lua_resMgr:SetImageTexture(self,self.rankImg, 'rank_image', "rank_ranksign"..self.data.rank ,true)
    else
        SetVisible(self.rankObj,true)
        SetVisible(self.rankImg.gameObject,false)
    end
end
function RankRightItem:SetTitle()
    local roleBase = self.data.base
    self.title_id = roleBase.figure.jobtitle and roleBase.figure.jobtitle.model
    self.title_id = self.title_id or 0
    local cur_config = Config.db_jobtitle[self.title_id]
    if not cur_config then
        self.nameTitleTex.text = ""
        return
    end
    self.nameTitleTex.text = cur_config.name
    local r,g,b,a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r,g,b,a)
    self:UpdateTitelPos()
    --print2(cur_config.name)
end

function RankRightItem:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local name_x = job_title_width + 20
    local job_title_x = -name_width * 0.5 - name_x
    SetLocalPositionX(self.name, name_x)
    --SetLocalPositionX(self.nameTitle, job_title_x)
end