local MailItem = calss("MailItem", function()
	return CCTableViewCell:new()
end)
function MailItem:create(param)
	return self
end
return MailItem