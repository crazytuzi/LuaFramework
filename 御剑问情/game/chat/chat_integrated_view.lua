ChatIntegratedView = ChatIntegratedView or BaseClass(BaseRender)

function ChatIntegratedView:__init()
end

function ChatIntegratedView:__delete()
	print("ChatIntegratedView.Release")
end

function ChatIntegratedView:FlushIntegratedView()
end