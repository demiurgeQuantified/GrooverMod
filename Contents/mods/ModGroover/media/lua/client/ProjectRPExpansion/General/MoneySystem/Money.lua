require('ProjectRP/General/MoneySystem/Money')

Events.OnFillInventoryObjectContextMenu.Remove(ProjectRP.Client.Money.PackMoneyContextOptions)
ProjectRP.Client.Money.WalletTypes = {Wallet = true, Wallet2 = true, Wallet3 = true, Wallet4 = true}