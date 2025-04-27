# invinc-sabotage
Custom mod to assist the Sabotage game mode for the 10 year release anniversary of Invisible Inc.

RULES
https://iiwiki.werp.site/community:sabotage:rules

Some mandatory task-structuring:
(Ref: <https://iiwiki.werp.site/daemons:index> )

These are just vanilla daemons and can be spawned in.
> blowfish2 - Blowfish 2.0
> fractal2 - Fractal 2.0
> modulate2 - Modulate 2.0
> portcullis2 - Portcullis 2.0

These are custom daemons that would need to be made, and then can be spawned in.
> alert - all guards at the start of the mission are alerted. **Tweak Alert daemon from PE.**
> chiton2 - Guards have permanent +2 armour. **Might already exist for Endless?** 
> labyrinth2 - Labyrinth for 20 turns
> echo2 - Every turn, a device is rebooted and recaptured [i.e. spawn Echo with 0% reversal chance]. **Just take Failsafe (from the Mainframe mission), change devices to 1 per turn and make it permanent. It already can't be reversed IIRC.**
> paradox2 - Paradox for 10 turns
> rubiks2 - All firewalls raised by 2 ~~at the start of the mission~~ when spawned.

I would recommend all of these be implemented as daemons as well. (Also, if they're daemons, then they **can** be used on story missions as long as the interface to spawn them in itself works on story missions.)

> lockdown - The exit is locked for 20 turns: **Tweak Gatekeeper from PE**
> nullcameras - Security Cameras cannot be hacked [not strictly necessary, it can be enforced manually]. **This exists in Manual Hacking.**
> pinpoint - Every turn, an agent is located [like a scanning amp]. **Easy, just reuse scan amp code i.e. alarm level 5/6 code and tie it to a daemon.**
> specoops - all non-civilian guards at the start of the mission are Spec Ops. **A bit trickier.**
> validoops - all daemons initially installed on mainframe devices are Validate. **Very easy.**
