require "luascript/script/game/gamemodel/bookmark/bookmarkVo"

bookmarkVoApi={
	allBookmarkVo={},
	maxNum=20,
	--测试数据
    data={},
	dataTest={
		{id=1,type={1,2,3},name="player1(Lv.20)",x=300,y=360},
		{id=2,type={},name="player1(Lv.20)",x=320,y=360},
		{id=3,type={3},name="player1(Lv.20)",x=300,y=310},
	},
}
function bookmarkVoApi:clearBookmark()
    for k,v in pairs(self.allBookmarkVo) do
         v=nil
    end
    for k,v in pairs(self.data) do
         v=nil
    end
    self.allBookmarkVo=nil
    self.allBookmarkVo={}
    self.data=nil
    self.data={}

end
function bookmarkVoApi:updateAll(data)
	self.allBookmarkVo={}
	if data then
		for k,v in pairs(data) do
		    local bvo = bookmarkVo:new()
		    bvo:initWithData(v.id,v.type,v.name,v.x,v.y)
	        table.insert(self.allBookmarkVo,bvo)
		end
	end
end

function bookmarkVoApi:getAllBookmark()
	if self.allBookmarkVo==nil then
		--self:updateAll(self.data)
	end
	return self.allBookmarkVo
end

function bookmarkVoApi:getBookmarkByType(type)
	local bookmarks={}
	local allBookmark=self:getAllBookmark()
	if type==nil or type==0 then
		bookmarks=allBookmark
	else
		for k,v in pairs(allBookmark) do
			if v.type then
				for m,n in pairs(v.type) do
					if n==type then
						table.insert(bookmarks,v)
					end
				end
			end
		end
	end

	local function sortFunc(a,b)
    	return a.t > b.t 
  	end
  	table.sort(bookmarks,sortFunc)

	return bookmarks
end

function bookmarkVoApi:getBookmarkNum(type)
	local bookmarks=self:getBookmarkByType(type)
	local num=SizeOfTable(bookmarks)
	return num
end

function bookmarkVoApi:isBookmark(x,y,type)
	local hasBookmark=false
	local allBookmark=self:getAllBookmark()
	for k,v in pairs(allBookmark) do
		if tostring(v.x)==tostring(x) and tostring(v.y)==tostring(y) then
			hasBookmark=true
			if type then
				hasBookmark=false
				for m,n in pairs(v.type) do
					if n==type then
						hasBookmark=true
					end
				end
			end
		end
	end
	return hasBookmark
end

function bookmarkVoApi:addBookmark(id,type,name,x,y,t)
	if self:isBookmark(x,y) then
		return false
	else
	    local bvo = bookmarkVo:new()
	    bvo:initWithData(id,type,name,x,y,t)
        table.insert(self.allBookmarkVo,bvo)
		return true
	end
end

function bookmarkVoApi:changeType(x,y,type)
	local hasType=false
	local allBookmark=self:getAllBookmark()
	local key
	for k,v in pairs(self:getAllBookmark()) do
		if tostring(v.x)==tostring(x) and tostring(v.y)==tostring(y) then
			key=k  
            if self.allBookmarkVo[k].type[type]==0 then
                self.allBookmarkVo[k].type[type]=type
            else
                self.allBookmarkVo[k].type[type]=0
            end

		end
	end

end

function bookmarkVoApi:deleteBookmark(x,y)
	local allBookmark=self:getAllBookmark()
	for k,v in pairs(allBookmark) do
		if tostring(v.x)==tostring(x) and tostring(v.y)==tostring(y) then
			table.remove(self.allBookmarkVo,k)
		end
	end
end

function bookmarkVoApi:getMaxNum()
	return self.maxNum
end


function bookmarkVoApi:changeText(x,y,str)
	local allBookmark=self:getAllBookmark()
	for k,v in pairs(allBookmark) do
		if tostring(v.x)==tostring(x) and tostring(v.y)==tostring(y) then
			self.allBookmarkVo[k].name=str
		end
	end
end