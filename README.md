# 🔁 Azure Refund System
- This was my first project I made for a game community in Garry's Mod using Lua
- A preview of this system can be found [here](https://www.youtube.com/watch?v=uZ470HQIdrM) on my YouTube
- This project uses the [Xenin Framework](https://gitlab.com/sleeppyy/xenin-framework) library to create the UI
## 👩‍💻 About the Project
- It is a simple input/output system that allows staff to refund players who lost their weapons
- It allows for configeration for the following:
  - API address and password
  - Staff ranks which can access the menu
  - Staff ranks that can bypass the abuse check
  - Weapons that cannot be refunded
- Once a user has entered all the information, it sends a netmessage to the server
- If the inputs are invalid, then the server will display a message to the client
- If the inputs are valid, then the following occurs:
  - The weapon is refunded to the target user
  - Both the client who sent the request and the target client see a success message
  - A message on Discord is logged by the API webhook
- The abuse check simply ensures staff do not refund 3 or more weapons in 10 minutes
- If a lot of weapons were refunded, this could break the economy and ruin the server experience
## 🚧 Improvement 
- Through the project you can see code such as:
```ply:SendLua("chat.AddText(XeninUI.Theme.Red, \"[ERROR] \", color_white, \"You are not allowed to use this!\")")```
- Since creating this project 3 years ago, I would now use my [library](https://github.com/kierancrossley/server-addtext/) to send a coloured chat message as it is less resource heavy
