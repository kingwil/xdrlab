# Prepare the Lab Environment.

The XDR lab consists of a dedicated Azure AD tenant, with an M365 E5 Trial License assigned.  We also use an Azure Pass promo code to link an Azure subscription in which to deploy Azure Defender and Azure Sentinel as well as hosting of VM's and lab resources.

To be completed.


## Lab deployment

ARM template will deploy and configure the following:

1x Domain Controller (WS2019) with some user accounts.
1x Member Server (WS2019)
2x Windows 10 Clients
Azure Sentinel Workspace
Azure Defender Enabled, configured to use Sentinel Workspace
Update Mangement & Change Tracking Solutions

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkingwil%2Fxdrlab%2Fmain%2FSources%2Fxdr-subscription.json)