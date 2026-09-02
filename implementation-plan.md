# Implementation Plan — Ectomorph Gym App
### Screen-by-screen UX concept for every feature, build sequence, no code

---

## How to read this document

For each feature from the spec, this plan describes: what the user actually sees and does, why it's built that way, and what makes the presentation distinct rather than a generic health-app template. Build order is phased at the end.

---

## 1. Onboarding & Personalization

**The problem with a normal onboarding flow:** 12 form fields in a row feels like filling out a tax form, and it's the #1 place apps lose users before they've felt any value.

**The concept — "Build your profile like a character sheet, not a form."**

Instead of a linear questionnaire, onboarding is framed as *calibrating the engine*, not filling in a database. Each question appears one at a time, full-screen, with a short line of reasoning underneath it explaining *why the app needs this* — "Your training age changes how much volume you can recover from" — so the user understands the app is computing something, not just collecting data.

Visual treatment: a thin progress ring builds around a central number as questions are answered — not a boring linear progress bar. By the final question, that ring is full and morphs into the user's first-ever TDEE number, revealed with a short animated build-up (numbers counting up, not just appearing) — the "hero moment" of onboarding. This is the first taste of the app's core value: *we just calculated something real about your body.*

Height/weight/age/sex entry uses large scroll-wheel pickers (tactile, fast) rather than keyboard text fields — keyboard entry on mobile for numeric data is friction with no upside.

Diet type, food budget, gym access, and injury flags are presented as tappable cards with icons (Phosphor, filled weight when selected) rather than dropdowns — dropdowns hide options; cards make the choice space visible at a glance.

The very last screen isn't a "submit" button — it's the reveal screen: surplus target, macro split, and assigned training split appear together as the user's "starting stats," styled like a character build summary. This reframes onboarding from *paperwork* to *here's your plan*, which is the emotional hook that gets someone into their first workout instead of abandoning the app on screen 9 of a form.

---

## 2. Nutrition

**Auto-adjusting surplus/macro engine**

The macro targets aren't presented as a static number that sits there unchanged like every other app. The dashboard's calorie/macro card visually shows *the trend that produced today's number* — a small sparkline behind the big number showing the last 2 weeks of weight trend, so the target visibly moves with the data instead of feeling arbitrary. When the weekly recalibration adjusts the surplus, the app doesn't just silently change the number — it surfaces a short one-line explanation card ("Your weight trend was flat this week, so surplus is up by 150 kcal") the first time it happens each week. This is the single feature most likely to build trust that the app is actually *doing* something, so it deserves visible narration rather than being a silent backend job.

**Barcode scanner**

Standard camera viewfinder UX, but with one distinct touch: a scan produces an immediate card showing where the food sits relative to *today's remaining macros*, not just its raw nutrition facts — e.g., a big visual bar showing "this covers 40% of today's remaining protein" rather than a flat number dump. Ties every scan back to the goal instead of feeling like a lookup tool.

**Indian-diet-native food database**

This is a differentiator, so it should look like one. Rather than burying dal/paneer/roti inside a generic search bar shared with everything else, the food-logging screen has a "Home Cooking" tab as a first-class peer to "Barcode" and "Search" — with common dishes shown as a visual grid (photo + name) instead of a text list, since these are usually logged by eye/portion rather than package weight. Portion selection uses relatable units already familiar in Indian kitchens — katori, roti count, spoon of ghee — as the default input unit, with grams available as a secondary toggle, not the primary interaction.

**Calorie-floor alerts**

Framed entirely differently from a diet app's "you're over budget" warning — this app's warning state is a low-fill progress ring with a nudge tone ("You're behind on calories today — here's a quick way to close the gap") paired with 2–3 one-tap calorie-dense suggestions (peanut butter spoon, banana-milk shake) pulled straight from the Indian food database. The alert *solves* the problem in the same card it presents it, rather than just flagging guilt.

---

## 3. Training

**Workout logger**

The core interaction is built for speed during a set, not for admiring a UI between sets. Each exercise card shows the previous session's numbers pre-filled and greyed out as a target/ghost — the user taps to confirm they hit it or slides to adjust, rather than retyping weight and reps from scratch every set. Rest timer runs as a persistent bottom sheet that stays visible while scrolling to the next exercise, with a subtle haptic pulse at 10 seconds remaining instead of a jarring alarm sound — gym environments are loud and social, silent-but-felt cues fit better than audio alerts.

Plate calculator isn't a separate tool buried in a menu — tapping the weight number on any set flips it into a plate-math visual (barbell diagram with plates stacking on each side) inline, then flips back. Keeps the user in the logging flow instead of routing them to a different screen.

**Templates + exercise library**

Templates are presented as visual session cards (exercise count, estimated duration, a small icon row of the muscle groups hit) that can be started with one tap from the dashboard — not a nested "My Templates" list three taps deep. Building a new template uses drag-to-reorder exercise cards rather than up/down arrow buttons, since reordering a workout is something people do by feel.

**Recovery-aware volume adjustment**

This is a backend-driven feature that needs a visible face or it's invisible value. When Health Connect/HealthKit data (sleep, resting HR trend) triggers a volume adjustment for the week, the training screen shows a small "Recovery" badge on affected days with a one-tap explanation ("Sleep was below your average 3 of the last 5 nights, so volume is trimmed ~15% this week") — same principle as the nutrition recalibration: silent automation reads as either magic or a bug; a one-line surfaced reason reads as intelligence.

---

## 4. Progress Tracking

**AI photo check-in**

This is the app's signature feature and should feel considered, not like a camera permission popup. The capture flow uses an on-screen silhouette guide (front-facing pose outline) so every photo is framed consistently — critical for the AI scoring to be comparable check-in to check-in, and it also makes the *process* feel professional, like a body-scan kiosk rather than a random selfie.

Results are never a bare number. The physique score reveal uses a build-up animation — per-muscle-group scores fill in one at a time (shoulders, chest, arms, legs, back) rather than dumping a full report at once — turning what could be a clinical readout into something that feels closer to a game stat reveal. Historical check-ins are browsable as a horizontal filmstrip with the score overlaid on each thumbnail, so progress is *seen* across a timeline, not just read as a line graph.

Because this feature is explicitly private and self-referential (per the confidence/wellbeing principle below), the comparison view is always "you vs. your own past" — a slider or side-by-side of two dates the user picks themselves, never a ranked or public view.

**Weight trend graph**

Deliberately smooths and de-emphasizes daily noise: the chart renders as a soft trend band (a shaded range, not a jagged connect-the-dots line) with the raw daily plot points shown faint and small underneath it. This is a design choice with a purpose — it visually teaches the user that day-to-day fluctuation isn't the number that matters, without needing a paragraph of explanation.

**Weekly consistency score**

Shown as a 7-segment ring (one segment per day) that fills as sessions are logged, sitting on the dashboard as one of the hero stats. Missing a day never removes a filled segment retroactively or resets anything — it simply stays unfilled, and the ring resets fresh at the start of the next week. No streak counter, no "days since last miss" — the whole point is that this metric can't be broken, only added to.

---

## 5. Wearable Integration

The wearable connection flow is presented as a single "Connect your watch" screen listing supported ecosystems (Health Connect / HealthKit) with brand logos for the common watches that sync into them (boAt, Noise, Samsung, Fitbit, Mi Band) shown underneath as "works with" — so a user searching for their specific budget brand sees it recognized by name, even though technically everything routes through the same platform layer. Avoids a confusing technical explanation of the sync chain; the user just needs to know their watch is supported.

A small "last synced" timestamp is shown quietly wherever wearable data feeds into a screen (recovery badge, dashboard steps card) — since sync isn't continuous for budget-brand watches, this manages expectations without needing a support ticket about "why isn't today's data showing."

---

## 6. Retention System

**Comeback flow**

This is the most emotionally important screen in the whole app, and it's designed to actively avoid every pattern that makes returning-after-a-miss feel bad. No red indicators, no "you missed 3 days" counter, no broken-streak animation. Reopening the app after a gap shows a calm, single-message screen — "Ready when you are" — with one clear button to jump straight into today's planned session. The consistency ring from before the gap is preserved exactly as it was, not reset or crossed out. The entire design intent is that missing days should be as low-friction to recover from as possible, because shame is the actual churn driver, not the missed session itself.

**WhatsApp/push nudges**

Nudge copy is written to sound like a training partner checking in, not a system notification — short, specific, non-generic ("Your legs session is still there whenever you're ready" rather than "You have a workout reminder"). Timed at the 24–48h mark after a miss specifically because same-day nudges read as nagging, and this matches the actual churn window shown by usage data.

**AI coach chat**

Presented as a bottom-sheet chat panel accessible from anywhere via a persistent small icon, not a separate full-screen tab — keeps it feeling like an assistant threaded through the app rather than a destination. Because it answers using the user's own logged data, responses are shown with small inline reference chips (e.g., a tappable "Tuesday's session" chip inside the answer) that jump to the relevant log entry — makes the coach feel grounded in the user's actual history rather than giving generic canned advice.

---

## 7. Confidence/Wellbeing Layer

**"Learn" tab**

Structured as short, mythbusting cards (one claim per card, swipeable) rather than long-form articles — matches how this misinformation actually spreads (short claims on social media), so the correction is delivered in the same format as the myth, which makes it more likely to actually land and be remembered.

**Growth-window checker**

Framed as a simple, honest calculator, not a diagnostic tool. Takes age and puberty-onset timing, outputs a plain-language likelihood band ("your growth window is most likely still open / most likely closed") with a clear, non-alarming pointer to get an actual bone-age X-ray for certainty — styled visually distinct from the rest of the app (a muted, informational card style) so it reads as an honest reference tool rather than a feature trying to sell false hope.

**AI coach flagging negative self-talk**

This should never feel like surveillance. When a check-in message contains language like "I look like a kid" or "I'll never look like a real man," the coach's response tone shifts to acknowledge it directly and briefly before returning to the practical answer — never a popup, never a separate "are you okay?" interruption. Support is woven into the same conversation, not flagged as a separate event.

**No public leaderboards/comparison**

This is as much a UX absence as a presence — deliberately no ranked list, no friend leaderboard, no public profile anywhere in the app. Worth stating explicitly in the plan because it's the kind of feature a future roadmap conversation will suggest adding for "engagement," and it directly contradicts the app's confidence-first design intent.

---

## 8. Monetization

**Razorpay / subscription**

The paywall moment is tied to a specific value trigger, not a generic "upgrade" banner — it appears right after the first free AI-generated insight (e.g., the first weekly recalibration explanation) rather than on a schedule or timer, so the user hits the paywall exactly when they've just felt what the paid tier gives more of. Checkout uses Razorpay's UPI flow as the default/first payment option shown, with cards as a secondary option — matches actual payment behavior for this user base rather than defaulting to a card-first Western checkout pattern.

---

## 9. Build Order (MVP Sequence)

Reiterating and locking in the sequence from earlier research, since it determines what gets wireframed and built first:

1. **Onboarding + TDEE/macro engine** — nothing else works without this
2. **Workout logger with templates** — the core daily-use loop
3. **Weekly adaptive recalibration** — the "surplus-first" differentiator that makes this app different from a generic tracker
4. **Photo body-comp scoring** — the signature feature, but needs the above data flowing first to be meaningful
5. **AI coach chat** — most expensive to get right, least needed to validate whether the core loop works at all

Wearable integration and the confidence/wellbeing layer can be built in parallel with steps 2–4 since they're additive rather than blocking. Monetization/paywall placement is last — implemented only once there's a real "aha" moment in the product to gate.

---

## 10. Next Step

Wireframe the four core screens in build order 1–4 above (onboarding flow, dashboard, workout logger, photo check-in) before writing any Flutter code — screen-by-screen layout, not full visual design yet.
