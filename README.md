# Randolio: Newspaper Delivery

Inspired by the GTA Online Acid Lab deliveries, this script allows you to be the ultimate newspaper boy. Get assigned a random area to deliver to with a set number of locations. You'll be handed the amount of newspapers to match the number of locations in that area. Pull up close until you see that pink draw marker, pull out your newspaper, aim and YEET it into the zone to deliver. Customizable areas, set locations and payouts per area.

If you miss a target and run out of newspapers, there is no second chances. You'll have to return to the guy and be paid for the ones you did complete.

**Notes**:

* FiveM Game Build 2802 (Los Santos Drug Wars) is required to use the WEAPON_ACIDPACKAGE.
* This was made to be used with **ONLY OX INVENTORY** due to it's flawless functionality, security and extra features like event hooks which are necessary for this script. You can use this in your server but you are not allowed to redistribute it anywhere.
* With the event hook, it stops the newspapers from being able to be put in gloveboxes/trunks/dropped. You may need to add to the inventory filter if you have more inventory types you want to block.
* If a player crashes/quits and then loads back in, they'll have the newspapers unable to be moved from their inventory. They will need to start delivery work and instantly end it to get these removed.
* I use qb-target exports for obviously the people who use qb-target and because ox_target has compatibility for these exports and will convert them, regardless if you have the qb-target resource or not. So both qb and ox target are supported.

# Installation

* Add this to your ox_inventory/data/weapons.lua. **WEAPONS** not items. This is a default gta throwable although it may not be in stock ox inventory.
```lua
['WEAPON_ACIDPACKAGE'] = {
    label = 'Newspaper',
    weight = 0,
    throwable = true,
},
```
* Image can be found in the [image] folder. Place this in ox_inventory\web\images.

* [ox_lib](https://github.com/overextended/ox_lib/releases/)
* [ox_inventory](https://github.com/overextended/ox_inventory/releases/)

## Showcase

* [showcase](https://streamable.com/y7w78q)

Many thanks to the overextended team for making this script possible. Go donate, star and download their resources. https://github.com/overextended

**You have permission to use this in your server and edit for your personal needs but are not allowed to redistribute.**
