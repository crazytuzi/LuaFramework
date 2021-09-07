-- ---------------------------------
-- 聊天大界面，置顶显示面版
-- ljh
-- ---------------------------------
TruthordareChatTopPanel = TruthordareChatTopPanel or BaseClass(BaseView)

function TruthordareChatTopPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordarechatpanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.data = nil
    self.isActive = true
    self.isShowPanel = false

    self.panel = nil

    self.timer = nil

    self.panelType = 1

    self._Update = function() self:Update() end

    self:LoadAssetBundleBatch()
end

function TruthordareChatTopPanel:__delete()
    self:SetActive(false)

    TruthordareManager.Instance.OnUpdate:Remove(self._Update)

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end

    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end
end

function TruthordareChatTopPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordarechatpanel))
    self.gameObject.name = "TruthordareChatTopPanel"
    -- UIUtils.AddUIChild(self.parent.transform, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector3.zero
    self.transform:SetAsFirstSibling()

    
    self.transform:Find("ShowButton"):GetComponent(Button).onClick:AddListener(function() self:OnShowButton() end)
    self.showButton = self.transform:Find("ShowButton")

    self.panel0 = self.transform:Find("Panel0")
    self.panel0_text3 = self.panel0:Find("Text3"):GetComponent(Text)

    self.panel1 = self.transform:Find("Panel1")
    self.panel1_text2 = self.panel1:Find("Text2"):GetComponent(Text)

    self.panel2 = self.transform:Find("Panel2")
    self.panel2_text2 = self.panel2:Find("Text2"):GetComponent(Text)
    self.panel2_boomText = self.panel2:Find("BoomBg/BoomText"):GetComponent(Text)

    self.panel3 = self.transform:Find("Panel3")
    self.panel3_text2 = self.panel3:Find("Text2"):GetComponent(Text)
    self.panel3_text2Ext = MsgItemExt.New(self.panel3_text2, 291, 16, 22)

    self.panel9 = self.transform:Find("Panel9")
    self.panel9_text1 = self.panel9:Find("Text"):GetComponent(Text)
    self.panel9_text1Ext = MsgItemExt.New(self.panel9_text1, 213, 16, 22)
    self.panel9_text2 = self.panel9:Find("Text2"):GetComponent(Text)
    self.panel9_text3 = self.panel9:Find("Text3"):GetComponent(Text)
    ----------------------------
    self:SetData(self.data)
    self:SetActive(self.isActive)
    self:ClearMainAsset()
end

function TruthordareChatTopPanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self:Update()
    self:OnShowButton(TruthordareManager.Instance.model.isShowPanel or TruthordareManager.Instance.model:IsBoomMan())
end

function TruthordareChatTopPanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)

        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
        end

        if active then
            self.timer = LuaTimer.Add(0, 1000, function() self:OnTimer() end)

            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            TruthordareManager.Instance.OnUpdate:Add(self._Update)
        else
            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
        end
    end

    if self.panel ~= nil then
        self.panel:SetActive(active and TruthordareManager.Instance.model.isShowPanel)
    end
end

function TruthordareChatTopPanel:OnShowButton(show)
    if show ~= nil then
        self.isShowPanel = show
    else
        self.isShowPanel = not self.isShowPanel
    end
    TruthordareManager.Instance.model.isShowPanel = self.isShowPanel

    if self.isShowPanel then
        self:OpenPanel()
        self.transform:Find("ShowButton/Image").localScale = Vector3(-1, 1, 1)
    else
        self:MiniPanel()
        self.transform:Find("ShowButton/Image").localScale = Vector3(1, 1, 1)
    end
end

function TruthordareChatTopPanel:Update()
    local data = TruthordareManager.Instance.model
    if data.state == 0 then
        self.showButton.gameObject:SetActive(false)
        self.panel0.gameObject:SetActive(true)
        self.panel1.gameObject:SetActive(false)
        self.panel2.gameObject:SetActive(false)
        self.panel3.gameObject:SetActive(false)
        self.panel9.gameObject:SetActive(false)
    elseif data.state == 1 or data.state == 2 then
        self.showButton.gameObject:SetActive(true)
        self.panel0.gameObject:SetActive(false)
        self.panel1.gameObject:SetActive(true)
        self.panel2.gameObject:SetActive(false)
        self.panel3.gameObject:SetActive(false)
        self.panel9.gameObject:SetActive(false)
        if data.vacancy > 0 then
            self.panel1_text2.text = string.format(TI18N("当前剩余空位: %s"), data.vacancy)
        else
            self.panel1_text2.text = TI18N("名额已满，活动即将开始!")
        end
    elseif data.state == 3 then
        self.showButton.gameObject:SetActive(true)
        self.panel0.gameObject:SetActive(false)
        self.panel1.gameObject:SetActive(false)
        self.panel2.gameObject:SetActive(true)
        self.panel3.gameObject:SetActive(false)
        local role_name = ""
        if data.boomMan ~= nil then
            role_name = data.boomMan.role_name
        end
        self.panel2_text2.text = string.format(TI18N("<color='#25EEF6'>%s</color>正在拆弹，幸运儿会是他吗？"), role_name)
        self.panel2_boomText.text = string.format(TI18N("爆炸范围：%s-%s"), data.min_num, data.max_num)
    elseif data.state == 4 or data.state == 5 or data.state == 6 or data.state == 7 then
        self.showButton.gameObject:SetActive(true)
        self.panel0.gameObject:SetActive(false)
        self.panel1.gameObject:SetActive(false)
        self.panel2.gameObject:SetActive(false)
        self.panel3.gameObject:SetActive(true)
        self.panel9.gameObject:SetActive(false)
        local role_name = ""
        if data.luckyMan ~= nil then
            role_name = data.luckyMan.name
        end
        if data.state == 4 then
            self.panel3_text2Ext:SetData(string.format(TI18N("    <color='#25EEF6'>%s</color>成为幸运儿\n    正在选择真心话或大冒险"), role_name))
        elseif data.state == 5 then
            if data.luckyQuestionType == 1 then
                self.panel3_text2Ext:SetData(string.format(TI18N("    <color='#25EEF6'>%s</color>选择了真心话！\n    等一个引爆场面的答案！{face_1,15}"), role_name))
            else
                self.panel3_text2Ext:SetData(string.format(TI18N("    <color='#25EEF6'>%s</color>选择了大冒险！\n快一起来看看有什么劲爆的展开吧！{face_1,53}"), role_name))
            end
        elseif data.state == 6 then
            if data.quest_round == 1 then
                self.panel3_text2Ext:SetData(string.format(TI18N("   <color='#25EEF6'>%s</color>已经完成了任务！\n    各位观众老爷是否满意呢？{face_1,56}"), role_name))
            else
                self.panel3_text2Ext:SetData(string.format(TI18N("   <color='#25EEF6'>%s</color>再次完成了任务！\n    各位观众老爷快给朵鲜花吧！"), role_name))
            end
        elseif data.state == 7 then
            if data.is_pass == 1 then
                self.panel3_text2Ext:SetData(string.format(TI18N("  <color='#25EEF6'>%s</color>精彩地完成了任务！\n    撒花奖励！{face_1,6}"), role_name))
            else
                if data.quest_round == 1 then
                    self.panel3_text2Ext:SetData(string.format(TI18N("  <color='#25EEF6'>%s</color>的表演还不够精彩哦~\n  还有一次机会，这次要加油哦~"), role_name))
                else
                    self.panel3_text2Ext:SetData(string.format(TI18N("  <color='#25EEF6'>%s</color>还是没能打动观众老爷\n  是不是应该发个红包给大家呀~{face_1,15}"), role_name))
                end
            end
        end
    elseif data.state == 8 or data.state == 9 then
        self.showButton.gameObject:SetActive(true)
        self.panel0.gameObject:SetActive(false)
        self.panel1.gameObject:SetActive(false)
        self.panel2.gameObject:SetActive(false)
        self.panel3.gameObject:SetActive(false)
        self.panel9.gameObject:SetActive(true)
        if data.state == 8 then
            self.panel9_text1Ext:SetData(TI18N("发红包倒计时！{face_1,31}"))
            self.panel9_text2.text = TI18N("手快有，手慢无！")
        elseif data.state == 9 then
            self.panel9_text1Ext:SetData(TI18N("下一轮倒计时！{face_1,31}"))
            self.panel9_text2.text = TI18N("约起来！各种劲爆题目等你来")
        end
    end
end

function TruthordareChatTopPanel:OpenPanel()
    local panelType = TruthordareManager.Instance.model:GetPanelType()
    if self.panel == nil or self.panel.panelType ~= panelType then
        if self.panel ~= nil and (self.panel.panelType == 2 and panelType == 3) then
            return
        end

        if self.panel ~= nil then
            self.panel:DeleteMe()
            self.panel = nil
        end
        if panelType == 1 then
            self.panel = TruthordareJoinPanel.New(self)
        elseif panelType == 2 then
            self.panel = TruthordareBoomPanel.New(self)
        elseif panelType == 3 then
            self.panel = TruthordareSelectPanel.New(self)
        elseif panelType == 4 then
            self.panel = TruthordareVotePanel.New(self)
        elseif panelType == 5 then
            self.panel = TruthordareSingleEndPanel.New(self)
        end
        if self.panel ~= nil then
            self.panel.panelType = panelType
        end
    end
    if self.panel ~= nil then
        self.panel:SetData(data)
    end
end

function TruthordareChatTopPanel:OnTimer()
    local data = TruthordareManager.Instance.model
    if data.state == 0 then
        local time = TruthordareManager.Instance.model.time - BaseUtils.BASE_TIME
        self.panel0_text3.text = string.format(TI18N("准备中 %s"), BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.MIN))
    elseif data.state == 8 or data.state == 9 then
        local time = TruthordareManager.Instance.model.time - BaseUtils.BASE_TIME
        if time >= 0 then
            self.panel9_text3.text = string.format(TI18N("%s秒"), time)
        end
    end
end

function TruthordareChatTopPanel:OpenGuidePanelFun()
    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end
    self.panel = TruthordareGuidePanel.New(self)
end

function TruthordareChatTopPanel:OpenEditorPanelFun()
    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end

    self.panel = TruthordareEditorWindow.New(self)
end

function TruthordareChatTopPanel:MiniPanel(andCloseChatPanel)
    if self.panel ~= nil then
        self.panel:MiniPanel(andCloseChatPanel)

        -- self.panel:DeleteMe()
        -- self.panel = nil
    end
    self.transform:Find("ShowButton/Image").localScale = Vector3(1, 1, 1)
end

function TruthordareChatTopPanel:ClosePanel()
    if self.panel ~= nil then
        self.panel:DeleteMe()
        self.panel = nil
    end
end