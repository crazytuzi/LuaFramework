--[[
邮件Util
liyuan
2014年9月27日10:12:24
]]

_G.MailUtil = {};

function MailUtil:GetViewStr()

end

--邮件排序
function MailUtil.MailSortFunc(A,B)
	--未读
	if A.read == 0 and B.read ~= 0 then
		return true;
	end
	if A.read ~= 0 and B.read == 0 then
		return false;
	end
	
	if A.item == 1 and B.item ~= 1 then
		return true
	end
	if A.item ~= 1 and B.item == 1 then
		return false;
	end
	
	--时间排序
	if A.sendTime > B.sendTime then
		return true
	else
		return false
	end
end

