PetEvaluationItem = PetEvaluationItem or BaseClass()

--为其他人的评论或者自己的评论信息处理逻辑
function PetEvaluationItem:__init(Parent,gameObject,data,specialIds)
    self.Parent = Parent
    self.gameObject = gameObject

    self.data = data
    self.specialIds = specialIds
    self.init = false
    self.selfHeight = 0
    self:InitPanel()
end

function PetEvaluationItem:InitPanel()

    self.transform = self.gameObject.transform
    self.NameText = self.transform:Find("Name"):GetComponent(Text)
    self.DownText = self.transform:Find("DownButton/Text"):GetComponent(Text)
    self.UpText =self.transform:Find("UpButton/Text"):GetComponent(Text)
    self.Msg = self.transform:Find("Msg"):GetComponent(Text)
    self.MsgExt = PetEvaluationMessageItem.New(self.Msg,550,20,22)



    self.MsgExt:SetData(self.data,self.specialIds)
    self.NameText.text = self.data.name
    self.DownText.text = tostring(self.data.con)
    self.UpText.text= tostring(self.data.pro)

    self.UpBtn = self.transform:Find("UpButton"):GetComponent(Button)
    self.DownBtn = self.transform:Find("DownButton"):GetComponent(Button)

    if self.data.vote_type ~= nil then
        if self.data.vote_type == EvaluationTypeEumn.Type.Pet then
             self.UpBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
             self.DownBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
        elseif self.data.vote_type == EvaluationTypeEumn.Type.ShouHu then
            self.UpBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
            self.DownBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
        end
    end


    self.UpBtn.onClick:AddListener(function()
        self:CheckUpButtonRequire()
      end)
    self.DownBtn = self.transform:Find("DownButton"):GetComponent(Button)
    self.DownBtn.onClick:AddListener(function()
         self:CheckDownButtonRequire()
      end)
    self:Layout()
end

function PetEvaluationItem:__delete()
    if self.MsgExt ~= nil then
        self.MsgExt:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.Parent ~= nil then
        self.Parent = nil
    end
end

function PetEvaluationItem:Layout()
    self.selfHeight = 50 + self.MsgExt.selfHeight
    self.transform.sizeDelta = Vector2(690,self.selfHeight)
    self.MsgExt.contentRect.anchoredPosition = Vector2(2,self.MsgExt.contentRect.anchoredPosition.y)
end


-- 判断是否符合点赞条件1
function PetEvaluationItem:CheckUpButtonRequire()

    if RoleManager.Instance.RoleData.id == self.data.role_id then
        NoticeManager.Instance:FloatTipsByString("玩家不能对自己发布的评论点赞或踩")
        return
    end
    local data = {id = self.data.m_id, platform = self.data.platform, zone_id = self.data.zone_id}
    self.Parent.evaluationTarget = self
    PetEvaluationManager.Instance:Send19402(data)
end

function PetEvaluationItem:CheckUpButtonRepley(data)
    self.data.pro = data.pro
    self.UpText.text= tostring(self.data.pro)
    self.UpBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
    local thumbData ={m_id = self.data.m_id,m_platform = self.data.m_platform,m_zone_id = self.data.m_zone_id,vote_type = 1}
    self.Parent:AddHasThumbList(thumbData)
    -- self.UpBtn.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
end



-- 判断是否符合点踩条件
function PetEvaluationItem:CheckDownButtonRequire()
    if RoleManager.Instance.RoleData.id == self.data.role_id then
        NoticeManager.Instance:FloatTipsByString("玩家不能对自己发布的评论点赞或踩")
        return
    end
    local data = {id = self.data.m_id, platform = self.data.platform, zone_id = self.data.zone_id}
    self.Parent.evaluationTarget = self
    PetEvaluationManager.Instance:Send19403(data)
end

function PetEvaluationItem:CheckDownButtonRepley(data)
    self.data.con = data.con
    self.DownText.text= tostring(self.data.con)
    self.DownBtn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
    local thumbData ={m_id = self.data.m_id,m_platform = self.data.m_platform,m_zone_id = self.data.m_zone_id,vote_type = 2}
    self.Parent:AddHasThumbList(thumbData)
end


-- function PetEvaluationItem:AddHasThumbList(data)
--     self.Parent:AddHasThumbList(data)
-- end
-- function PetEvaluationItem:ReplyUpDownButtonRequire()
--      local

--     -- 点赞次数需要开机获得
--     -- if self.giveThumbsTimes >=20 then
--     --     NoticeManager.Instance:FloatTipsByString("今天已经赞过太多次了~休息一下吧{face_1, 3}")
--     -- end

--     -- NoticeManager.Instance:FloatTipsByString("已经赞过该评论了哟~{face_1, 7}")
--     -- NoticeManager.Instance:FloatTipsByString("已经踩过该评论了哟~{face_1, 7}")
-- end

