require "Core.Info.ProductInfo";

DressDataManager = { }

DressDataManager.MESSAGE_DRESS_CHANGE = "MESSAGE_DRESS_CHANGE";

function DressDataManager.Init(data)
     MessageManager.Dispatch(DressDataManager,DressDataManager.MESSAGE_DRESS_CHANGE); 
end


