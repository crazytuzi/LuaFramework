RechargePackItem = RechargePackItem or BaseClass()

function RechargePackItem:__init(gameObject,isHasDoubleClick)
     self.slot = ItemSlot.New(gameObject,isHasDoubleClick)
end


function RechargePackItem:ShowMySelectImg(t)
    self.signRewardSelect.gameObject:SetActive(t)
end

function RechargePackItem:ShowGetImg(t)
    self.showGet.gameObject:SetActive(t)
end

function RechargePackItem:ShowEffect(t,id)
    if t == true then
        if self.effect == nil then
             if id == 1 then
                self.effect = BibleRewardPanel.ShowEffect(20223, self.slot.transform, Vector3(1, 1, 1), Vector3(32, 0, -400))
             elseif id == 2 then
                self.effect = BibleRewardPanel.ShowEffect(20223, self.slot.transform, Vector3(1, 1, 1), Vector3(32, -32, -200))
             end
             self.effect:SetActive(true)
        end
    elseif t == false then
        if self.effect ~= nil then
           self.effect:DeleteMe()
        end
    end
end

function RechargePackItem:__delete()
  if self.effect ~= nil then
    self.effect:DeleteMe()
  end
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end
end
