
local PortraitSelectPanel = Ui:CreateClass("PortraitSelectPanel");
 
PortraitSelectPanel.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME);
    end,

    BtnSource = function (self)
        local _1, _2, szOpenUi = self:GetDesc(self.nSelectPortrait or -1)
        if szOpenUi and szOpenUi ~= "" then
            Ui:OpenWindow(szOpenUi);
        end
    end,

    BtnHead = function (self)
        self:OpenHeadPanel();
    end,

    BtnBust = function (self)
        self:OpenBustPanel();
    end
}

PortraitSelectPanel.nSelectPortrait = nil; --当前选中的头像ID
PortraitSelectPanel.tbPortraits = nil; --玩家可以选择的头像列表
PortraitSelectPanel.nSelectBigFaceId = nil; --当前选中的半身像ID
PortraitSelectPanel.tbBigFaces = nil; --玩家可以选择的半身像列表

function PortraitSelectPanel:OnOpen()
    self.pPanel:Toggle_SetChecked("BtnHead", true);
    self.pPanel:Toggle_SetChecked("BtnBust", false);
    self:UpdatePortraitList();
    self.nSelectPortrait = me.nPortrait;
    self.nSelectBigFaceId = PlayerPortrait:GetBigFaceId(me);
    self:OpenHeadPanel();
end

function PortraitSelectPanel:OpenHeadPanel()
    self.pPanel:Label_SetText("Title","头像选择");
    self:UpdateScrollView()
    self.pPanel:SetActive("HeadScrollView",true);
    self.pPanel:SetActive("BustScrollView",false);
    self.bBtnHead = true;
    self.bBtnBust = false;
    self:UpdateDetail();
end

function PortraitSelectPanel:OpenBustPanel()
    self.pPanel:Label_SetText("Title","画像选择");
    self:UpdateBigFaceScrollView()
    self.pPanel:SetActive("HeadScrollView",false);
    self.pPanel:SetActive("BustScrollView",true);
    self.bBtnHead = false;
    self.bBtnBust = true;
    self:UpdateDetail();
end

function PortraitSelectPanel:OnClose()
    RemoteServer.ChangePortrait(self.nSelectPortrait);
    RemoteServer.ChangeBigFace(self.nSelectBigFaceId);
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_BIGFACE, self.nSelectBigFaceId);
end


function PortraitSelectPanel:UpdatePortraitList()
    self.tbPortraits, self.tbBigFaces = PlayerPortrait:GetShowList()
end

function PortraitSelectPanel:UpdateScrollView()
    local fnClickItem = function (buttonObj)
        local nPortrait = buttonObj.nPortrait;
        self.nSelectPortrait = nPortrait;
        self:UpdateDetail();
        self:UpdateScrollView();
    end

    local fnSetItem = function (itemObj, nIndex)
        for i = 1, 4 do
            local nSuffix = (nIndex - 1) * 4 + i;
            local nId = self.tbPortraits[nSuffix];
            local bShow = nId or false
            itemObj.pPanel:SetActive("Head"..i, bShow);
            itemObj.pPanel:SetActive("SpRoleHead"..i, bShow);
            itemObj.pPanel:SetActive("SelectMark"..i, bShow and self.nSelectPortrait == nId);

            if bShow then
                itemObj["Head"..i].nPortrait = nId;
                itemObj["Head"..i].pPanel.OnTouchEvent = fnClickItem;

                local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(nId)
                itemObj.pPanel:Sprite_SetSprite("SpRoleHead"..i, szSprite, szAtlas);
            end
            itemObj.pPanel.OnTouchEvent = nil;
        end
    end

    local nLen = math.ceil(#(self.tbPortraits)/4);
    self.HeadScrollView:Update(nLen, fnSetItem);
end

function PortraitSelectPanel:UpdateBigFaceScrollView()
    local fnClickItem = function (buttonObj)
        local nBigFaceID = buttonObj.nBigFaceID;
        self.nSelectBigFaceId = nBigFaceID;
        self:UpdateDetail();
        self:UpdateBigFaceScrollView();
    end

    local fnSetItem = function (itemObj, nIndex)
        for i = 1, 3 do
            local nSuffix = (nIndex - 1) * 3 + i;
            local nId = self.tbBigFaces[nSuffix];
            local bShow = nId or false
            itemObj.pPanel:SetActive("Bust"..i, bShow);
            itemObj.pPanel:SetActive("RoleBust"..i, bShow);
            itemObj.pPanel:SetActive("SelectMark"..i, bShow and self.nSelectBigFaceId == nId);

            if bShow then
                itemObj["Bust"..i].nBigFaceID = nId;
                itemObj["Bust"..i].pPanel.OnTouchEvent = fnClickItem;

                local szSprite, szAtlas = PlayerPortrait:GetPortraitBigIcon(nId)
                itemObj.pPanel:Sprite_SetSprite("RoleBust"..i, szSprite, szAtlas);
            end
            itemObj.pPanel.OnTouchEvent = nil; 
        end
    end
    local nLen = math.ceil(#(self.tbBigFaces)/3);
    self.BustScrollView:Update(nLen, fnSetItem);
end

function PortraitSelectPanel:Update()
    self:UpdatePortraitList();
    self:UpdateScrollView();
    self:UpdateDetail();
end

function PortraitSelectPanel:UpdateDetail()
    local nDecsId = self.nSelectPortrait;
    if self.bBtnBust == true then
        nDecsId = self.nSelectBigFaceId;
    end
    local szDesc, szLimit, szOpenUi = PlayerPortrait:GetDesc(nDecsId);
    local szDesc = string.gsub(szDesc or "", "\\n", "\n") 

    self.pPanel:Label_SetText("HeadDetails", szDesc or "");
    self.pPanel:Label_SetText("AccessWay", szLimit or "");

    local szIcon, szIconAtlas = PlayerPortrait:GetPortraitBigIcon(self.nSelectBigFaceId)
    self.pPanel:Sprite_SetSprite("Head", szIcon, szIconAtlas);

    szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(self.nSelectPortrait)
    self.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szIconAtlas);

    if szOpenUi and szOpenUi ~= "" then
        self.pPanel:SetActive("BtnSource", true);
    else
        self.pPanel:SetActive("BtnSource", false);
    end
end

function PortraitSelectPanel:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ADD_PORTRAIT,              self.Update},
        
    };

    return tbRegEvent;
end