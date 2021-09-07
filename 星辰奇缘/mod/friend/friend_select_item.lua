FriendSelectItem = FriendSelectItem or BaseClass()

function FriendSelectItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

end



function FriendSelectItem:InitPanel(_data)
    self:update_my_self(_data)
end

--更新内容
function FriendSelectItem:update_my_self(_data, _index)
    self.parent:SetPlayerItem(self.gameObject, _data)
end


