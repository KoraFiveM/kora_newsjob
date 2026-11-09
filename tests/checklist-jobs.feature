# Converted from the communitybot legacy tests by kora-qa-panel/scripts/convert-legacy.mjs.
# The """ block under each Scenario is the original test text, verbatim. Review before applying.
Feature: kora_newsjob — Jobs

  @kora_newsjob @checklist @checklist:kora_newsjob:news-blip @cat:jobs @manual
  Scenario: Garage blip for news employees
    """
    Checklist test: As job 'news' check the map for the vehicle blip at (-552.24,-925.61); other jobs do not get it.
    """
    When I manually: become a Weazel News employee (job 'news')
    And I manually: open the map and look at the Weazel News garage area
    Then I confirm: a vehicle blip is shown at the news garage
    When I manually: switch to a non-news job such as unemployed
    And I manually: open the map and look at the Weazel News garage area again
    Then I confirm: no garage vehicle blip is shown

  @kora_newsjob @checklist @checklist:kora_newsjob:enter-building @cat:jobs
  Scenario: Enter news building
    """
    Checklist test: As news at outside door (-598.25,-929.86,23.86) use target 'Enter'; screen fades and you arrive at (-77.46,-833.77,243.38).
    """
    Given I am at -598.25, -929.86, 23.86
    When I manually: become a Weazel News employee (job 'news')
    And I select the "Enter" target option
    Then I confirm: my screen fades
    And I confirm: I arrive inside the Weazel News building at the interior spawn point

  @kora_newsjob @checklist @checklist:kora_newsjob:exit-building @cat:jobs
  Scenario: Exit news building
    """
    Checklist test: Inside at (-77.46,-833.77,243.38) use target 'Exit'; fade and arrive outside. Non-news players get no target.
    """
    Given I am at -77.46, -833.77, 243.38
    When I manually: become a Weazel News employee (job 'news')
    And I select the "Exit" target option
    Then I confirm: my screen fades and I arrive outside the Weazel News building
    When I manually: switch to a non-news job such as unemployed and go inside the Weazel News building
    Then I confirm: no 'Exit' target option is shown

  @kora_newsjob @checklist @checklist:kora_newsjob:garage-vehicle @cat:jobs
  Scenario: Weazel News garage - van
    """
    Checklist test: As news at the garage box zone use the vehicles target; menu lists Rumpo; 'Take vehicle' spawns it, warps you in, WZNW plate, keys, full fuel, livery.
    """
    When I manually: become a Weazel News employee (job 'news')
    And I manually: go to the Weazel News garage box zone
    And I manually: use the vehicles target
    Then I confirm: the menu lists Rumpo
    When I manually: choose Rumpo and select 'Take vehicle'
    Then I should be in a vehicle
    And I should be in the driver seat
    And I confirm: the van spawned has a WZNW plate
    And I confirm: I have the keys to the van
    And I confirm: the van has full fuel
    And I confirm: the van has the Weazel News livery

  @kora_newsjob @checklist @checklist:kora_newsjob:garage-heli @cat:jobs
  Scenario: Weazel News garage - helicopter
    """
    Checklist test: At the heli pad (-583.08,-930.55,36.83) use the helicopters target; take Conada; spawns with livery and you are placed in it.
    """
    Given I am at -583.08, -930.55, 36.83
    When I manually: become a Weazel News employee (job 'news')
    And I manually: use the helicopters target
    And I manually: choose Conada and take it
    Then I should be in a vehicle
    And I confirm: the Conada spawned with the Weazel News livery
    And I confirm: I am placed in the Conada

  @kora_newsjob @checklist @checklist:kora_newsjob:van-trunk-items @cat:jobs
  Scenario: News van trunk equipment
    """
    Checklist test: Spawn the Rumpo and open its trunk; contains newscam, newsmic and newsbmic.
    """
    When I manually: become a Weazel News employee (job 'news') and spawn the Rumpo from the garage
    And I manually: get out and open the trunk of the Rumpo
    Then the "trunk" inventory opens
    And I confirm: the trunk contains newscam, newsmic and newsbmic

  @kora_newsjob @checklist @checklist:kora_newsjob:garage-job-gate @cat:jobs
  Scenario: Garage restricted to news job
    """
    Checklist test: As non-news job try the garage targets (no option shown) and spawn is refused server-side.
    """
    Given my job is "unemployed"
    When I manually: go to the Weazel News garage and look at the garage targets
    Then I confirm: no garage target option is shown
    And I confirm: I cannot obtain a garage vehicle by any other means (the server refuses the spawn)

  @kora_newsjob @checklist @checklist:kora_newsjob:garage-proximity @cat:jobs @manual
  Scenario: Spawn needs proximity to garage
    """
    Checklist test: Server only spawns the vehicle when player is within 5m of the garage point.
    """
    When I manually: become a Weazel News employee (job 'news')
    And I manually: try to spawn a garage vehicle while more than 5 metres from the garage point
    Then I confirm: the server does not spawn the vehicle
    When I manually: go to the garage point and spawn a vehicle within 5 metres
    Then I confirm: the vehicle spawns

  @kora_newsjob @checklist @checklist:kora_newsjob:equipment-shop @cat:jobs
  Scenario: Take news equipment
    """
    Checklist test: At shop (-595.4,-929.9,23.86) target 'Take news camera' / 'Take boom mic' / 'Take hand mic'; item added to inventory.
    """
    Given I am at -595.4, -929.9, 23.86
    When I manually: become a Weazel News employee (job 'news')
    And I select the "Take news camera" target option
    Then my "newscam" count should have changed by 1
    When I select the "Take boom mic" target option
    Then my "newsmic" count should have changed by 1
    When I select the "Take hand mic" target option
    Then my "newsbmic" count should have changed by 1

  @kora_newsjob @checklist @checklist:kora_newsjob:use-news-camera @cat:jobs
  Scenario: Use news camera item
    """
    Checklist test: Use newscam: camera prop and anim, Weazel News recording overlay 'NEWS CAM 01'; use again or close to stop.
    """
    Given I have 1 "newscam"
    When I use the "newscam"
    Then I confirm: a camera prop is held and the camera animation plays
    When the HUD should show "NEWS CAM 01"
    And I use the "newscam"
    Then I confirm: the camera prop, animation and overlay are removed

  @kora_newsjob @checklist @checklist:kora_newsjob:use-boom-mic @cat:jobs
  Scenario: Use boom mic item
    """
    Checklist test: Use newsmic: boom mic prop attaches with boom animation; using again removes it.
    """
    Given I have 1 "newsmic"
    When I use the "newsmic"
    Then I confirm: a boom mic prop is attached and the boom animation plays
    When I use the "newsmic"
    Then I confirm: the boom mic prop is removed

  @kora_newsjob @checklist @checklist:kora_newsjob:use-hand-mic @cat:jobs
  Scenario: Use hand mic item
    """
    Checklist test: Use newsbmic: handheld mic prop and hold animation; using again removes it.
    """
    Given I have 1 "newsbmic"
    When I use the "newsbmic"
    Then I confirm: a handheld mic prop is held and the hold animation plays
    When I use the "newsbmic"
    Then I confirm: the handheld mic prop is removed

  @kora_newsjob @checklist @checklist:kora_newsjob:equipment-auto-remove @cat:jobs @needs:admin
  Scenario: Equipment removed on death/job change
    """
    Checklist test: While holding equipment die or change job; prop and animation are removed automatically.
    """
    Given I have 1 "newscam"
    When I use the "newscam"
    And I run the command "/kill"
    Then I should be dead
    And I confirm: the equipment prop and animation are removed
    When I manually: revive, use the news equipment again and change to a non-news job
    Then I confirm: the equipment prop and animation are removed automatically

  @kora_newsjob @checklist @checklist:kora_newsjob:equipment-job-gate @cat:jobs
  Scenario: Equipment items need news job
    """
    Checklist test: As non-news player use newscam/newsmic/newsbmic; nothing happens.
    """
    Given my job is "unemployed"
    And I have 1 "newscam"
    And I have 1 "newsmic"
    And I have 1 "newsbmic"
    When I use the "newscam"
    And I use the "newsmic"
    And I use the "newsbmic"
    Then I confirm: nothing happens, no prop or animation appears
