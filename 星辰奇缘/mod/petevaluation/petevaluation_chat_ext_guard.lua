PetEvaluationChatExtGuard = PetEvaluationChatExtGuard or BaseClass(ChatExtGuard)


function PetEvaluationChatExtGuard:SetList(myList)
     self.myList = myList
end

function PetEvaluationChatExtGuard:Refresh(list)
    local count = 0
	 for i,guard in ipairs(self.myList) do
        count = i
        local tab = self.itemTab[i]
        tab["guardData"] = guard
        tab["nameTxt"].text = guard.name
        tab["levTxt"].text = string.format(TI18N("等级:%s"), RoleManager.Instance.RoleData.lev)
        tab["headImg"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard.avatar_id))
        tab["match"] = string.format("%%[%s%%]", guard.name)
        tab["append"] = string.format("[%s]", guard.name)
        tab["send"] = string.format("{guard_2,%s}", guard.base_id)
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end