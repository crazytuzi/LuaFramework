BotPresent = BotPresent or BaseClass()

function BotPresent:__init(gameObject, index, main)
    self.gameObject = gameObject
    self.transform = self.gameObject.transform
    self.data = main.topItemList[index]
    self.assetWrapper = main.assetWrapper
end