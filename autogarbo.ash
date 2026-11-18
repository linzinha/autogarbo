string stash_clan = "free";
string social_clan = "cool";

void setProperties() {
	set_property("_pregarboTurns", turns_played());
	set_property("_cr_finished", false);
	set_property("_fr_finished", false);
	set_property("_fr_advs", 0);
	set_property("_rubee_start", item_amount($item[Rubee&trade;]));
	set_property("_ltt_finished", false);
	set_property("_ltt_advs", 0);
	set_property("_pr_finished", false);
	set_property("_pr_advs", 0);
	set_property("_fpoints_start", get_property("availableFunPoints").to_int());
	set_property("_variables_initialized", true);
	print("properties initialized", "purple");
}


// do additional dailies not handled by breakfast
void secondBreakfast() {
	if (!get_property("breakfastCompleted").to_boolean()) {
		cli_execute("breakfast");
	}
	use_skill(1, $skill[Pirate Bellow]);
	use_skill(1, $skill[Generate Irony]); 
	use(1, $item[circle drum]); 
	use(1, $item[eternal car battery]); 
	use(1, $item[wardrobe-o-matic]); 
	cli_execute("store_mall_data");
	// TODO add garden logic back in
}


// clan stash handling
void stashHandler(string action, string stash_clan, string social_clan) {
	cli_execute("clanhop " + stash_clan);
	foreach it in $items[Buddy Bjorn, Crown of Thrones, mafia pointer finger ring, Operation Patriot Shield] {
		if (action == "put") {
			put_stash(1, it);
			print(it + " returned!", "green");
		}
		if (action == "take") {
			take_stash(1, it);
			print(it + " taken!", "green");

		} 
	}
	cli_execute("clanhop " + social_clan);
}


// run chibiparent if chibi will be 2 or more days old and not freshly ascended, otherwise calls chibi chat
void runChibi() {
	if (get_property("_chibiChanged").to_boolean() != true) {
		cli_execute("refresh inv");
		int chibi_on = item_amount($item[ChibiBuddy&trade; (on)]);
		int chibi_off = item_amount($item[ChibiBuddy&trade; (off)]);
		if (chibi_on == 0 && chibi_off > 0) {
			print("Chibi is not turned on");
			cli_execute("chibi chat");
		}
		if (chibi_on > 0) {
			print("Number of Chibis turned on: " + chibi_on);
			cli_execute("chibiparent");
		}
	}
}

// run garbo turns
// TODO add ability to set quick and diet, low priority for now
void runGarbo(int turns, boolean quick, boolean diet) {
	string command = "garbo target cockroach";

	if (turns != 0) {
		command += " turns " + turns;	
	}
	if (quick == true) {
		command += " quick";
	}
	if (diet == false) {
		command += " nodiet";
	}
	if (get_property("_khl_ascend").to_boolean()) {
		command += " ascend";
	}
	cli_execute(command);
}

void cyberRealmSetup() {
	outfit("Cyberrealm");
	equip($slot[familiar], $item[familiar-in-the-middle wrapper]);
	print("Adventuring in the Cyberrealm", "green");
	cli_execute("mcd 0");
	cli_execute("mood soothingpresence");
	set_ccs("cyberrealm");
}


// run cyberrealm first if set
void hackTheWorld() {
	// exit function if ran or not running
	if (get_property("_cr_finished").to_boolean() || !get_property("_khl_realm_cr").to_boolean()) return;
	// set up for cyberRealm
	if (get_property("_cr_advs").to_int() < 1) {
		cyberRealmSetup();
		set_property("_cr_advs", my_adventures());
	}

	// run cyberRealm turns
	while (!get_property("_cr_finished").to_boolean()) {
		// set finish conditions to break the loop
		if (get_property("_cyberZone1Turns").to_int() == 20 &&
			get_property("_cyberZone3Turns").to_int() == 20 &&
			get_property("_cyberZone2Turns").to_int() == 20) {
				print("The cyberrealm has been completed", "green");
				set_property("_cr_advs", get_property("_cr_advs").to_int() - my_adventures());
				set_property("_cr_finished", true);
				equip($slot[familiar], $item[tiny stillsuit]);
		} else {
			// adventure
			cli_execute("interjector full");
			if (get_property("_ccs_changed").to_boolean()) {
				set_property("_ccs_changed", false);
				cyberRealmSetup();
			}
			// TODO this loop logic is fine for now, but looked at
			if (get_property("_cyberZone3Turns").to_int() < 20) adv1($location[Cyberzone 3],-1,"");
			if (get_property("_cyberZone2Turns").to_int() < 20) adv1($location[Cyberzone 2],-1,"");
			if (get_property("_cyberZone1Turns").to_int() < 20) adv1($location[Cyberzone 1],-1,"");
		}
	}
}

// run fantasyrealm if set
void runFr() {
	// exit function if ran or not running
	if (get_property("_fr_finished").to_boolean() || !get_property("_khl_realm_fr").to_boolean()) return;

	// initialize fantasyRealm
	// TODO - this currently accounts for LGR gems before this is run but not after - is this what I want?
	if (get_property("_fr_advs").to_int() < 1) set_property("_fr_advs", my_adventures());
	
	// run fantasyRealm script
	cli_execute("fantasyrealm gems");

	// set finish conditions if run
	if (get_property("_frHoursLeft").to_int() == 0) {
		set_property("_track_rubies", item_amount($item[Rubee&trade;]) - get_property("_rubee_start").to_int());
		set_property("_fr_advs", get_property("_fr_advs").to_int() - my_adventures());
		set_property("_fr_finished", true);
		return;
	}
}

// run LT&T
void runLtt() {
	// exit function if ran or not running
	if (get_property("_ltt_finished").to_boolean() || !get_property("_khl_realm_ltt").to_boolean()) return;

	// initialize ltt
	if (get_property("_ltt_advs").to_int() < 1) set_property("_ltt_advs", my_adventures());

	// run ltt script
	cli_execute("telegram");

	// set finish conditions if run
	set_property("_ltt_finished", true);

}

// run or finish pirateRealm
void runPr() {
	// exit function if ran or not running
	if (get_property("_pr_finished").to_boolean() || !get_property("_khl_realm_pr").to_boolean()) return;

	// initialize pirateRealm
	if (get_property("_pr_advs").to_int() < 1) set_property("_pr_advs", my_adventures());

	// run pirateRealm script
	// TODO incorporate my prcheck script
	if (get_property("_questPirateRealm") != "finished") {
		set_ccs("dumpturns");
		cli_execute("piraterealm any");
	}
	// TODO replace unnecessary user created variables if existing ones can do the job


	// set finish conditions if run
	if (get_property("_questPirateRealm") == "finished") {
		set_property("_track_fpoints", get_property("availableFunPoints").to_int() - get_property("_fpoints_start").to_int());
		set_property("_pr_advs", get_property("_pr_advs").to_int() - my_adventures());
		set_property("_pr_finished", true);
	}

}

void runReports() {
	if (get_property("_frHoursLeft").to_int() == 0) {
		print("FantasyRealm final report", "purple");
		print("You gained " + get_property("_track_rubies") + " rubees!", "purple");
		print("You have " + item_amount($item[Rubee&trade;]) + " rubees total", "purple");
		print("");

	} else {
		print("You did not complete fantasyrealm", "red");
	}

	// PR Report
	if (get_property("_questPirateRealm") == "finished") {
		print("PirateRealm final report!", "green");
		print("You gained " + get_property("_track_fpoints") + " fun points!", "green");
		print("You have " + get_property("availableFunPoints") + " fun points total", "green");
		
		print("");
	} else {
		print("You did not complete piraterealm", "red");
	}

	print("");

	int post_garbo_turns = get_property("_fr_advs").to_int() + get_property("_pr_advs").to_int() + get_property("_cr_advs").to_int() + get_property("_ltt_advs").to_int();
	print("In total, you spent " + (turns_played() - get_property("_pregarboTurns").to_int()) + " turns with garbo!", "blue");
	print("");
	print("In total, you spent " + post_garbo_turns + " turns outside garbo!", "blue");
	print("FantasyRealm took " + get_property("_fr_advs") +" turns!", "purple"); // usually 45-46
	print("PirateRealm took " + get_property("_pr_advs") +" turns!", "green"); // usually 23, maybe 25 OR 45?
	print("CyberRealm took " + get_property("_cr_advs") +" turns!", "orange"); // 45-47 ish?
	print("LT&T took " + get_property("_ltt_advs") +" turns!", "orange"); // 91 - 81, about 30/run?
	

	print("");
	print("");

	// Chibi Report
	cli_execute("chibi");
	print("");
	cli_execute("skelestore");
}

string help_row(string arg, string desc) {
	return "<tr><td valign=top><b>" + arg + "</b></td><td>" + desc + "</td></tr>";
}

string help_sub(string desc) {
	return "<tr><td></td><td><font color=gray>&nbsp;&nbsp;" + desc + "</font></td></tr>";
}

void khl_help() {
	string spend = get_property("ltt_maxSpend");
	if (spend == "") spend = "not set";

	buffer b;
	b.append("<font color=blue><b>autogarbo &lt;args&gt;</b></font>");
	b.append("<table cellspacing=0 cellpadding=2>");
	b.append(help_row("full", "normal run with all realms"));
	b.append(help_row("ascend", "runs garbo ascend"));
	b.append(help_row("realms=ltt,fr,pr,cr", "runs only the selected realms"));
	b.append(help_sub("ltt &ndash; 30 &times; ltt count"));
	b.append(help_sub("fr &ndash; 45 turns"));
	b.append(help_sub("pr &ndash; 45 turns"));
	b.append(help_sub("cr &ndash; 46 turns"));
	b.append(help_row("ltt=0|1000|10000", "meat to spend, up to 3 telegrams"));
	b.append(help_sub("currently set to: " + spend));
	b.append(help_row("returnstash", "only returns stash items"));
	b.append(help_row("help", "this list"));
	b.append("</table>");

	print_html(b.to_string());
}



boolean parseArgs(string args) {
	foreach i, a in split_string(to_lower_case(args), "\\s+") {
		if (a == "" || a == "full") {
			set_property("_khl_realm_ltt", true);
			set_property("_khl_realm_fr", true);
			set_property("_khl_realm_pr", true);
			set_property("_khl_realm_cr", true);
			continue;
		}
		if (a == "help") { khl_help(); return false; }
		if (a == "returnstash") { stashHandler("put", stash_clan, social_clan); return false; }
		if (index_of(a, "realms=") == 0) {
			foreach j, realm in split_string(substring(a, 7), ",") {
				if (realm != "") {
					set_property("_khl_realm_" + realm, "true");
				}
			}
			continue;
		}
		if (index_of(a, "ltt=") == 0) {
			int ltt_current_value = get_property("ltt_maxSpend").to_int();
			int ltt_new_value = substring(a, 4).to_int();
			if (ltt_current_value != ltt_new_value) {
				set_property("ltt_maxSpend", ltt_new_value);
			} else {
				print("LTT already set to " + ltt_current_value);
			}
			continue;
		}
		if (a == "ascend") {
			set_property("_khl_ascend", true);
			continue;
		}
		print("Unknown argument: " + a, "red");
		khl_help();
		return false;
	}
	return true;
}

void main(string args) {
	int ltt_runs;
	int garbo_turns = 0;
	string autumn_maton_location = "Shadow Rift"; // TODO try hunting for oil
	print("Turns run before garbo: " + turns_played());
	if (!parseArgs(args)) return;

	// Set minus turns based on selected realms
	// LT&T
	if (get_property("_khl_realm_ltt").to_boolean()) {
		print("LT&T's max spend is stet to: " + get_property("ltt_maxSpend"), "orange");
		switch(get_property("ltt_maxSpend").to_int()) {
			case 0:
				garbo_turns -= 30;
				break;
			case 1000:
				garbo_turns -= 60;
				break;
			case 10000:
				garbo_turns -= 90;
				break;
		}
	}

	// Take from the stash for non-garbo turns as well
	// string action, string stash_clan, string social_clan)
	stashHandler("take", stash_clan, social_clan);

	// FantasyRealm
	if (get_property("_khl_realm_fr").to_boolean()) {
		garbo_turns -= 46;
	}

	// PirateRealm
	if (get_property("_khl_realm_pr").to_boolean()) {
		if (get_property("_questPirateRealm") == "unstarted") {
			garbo_turns -= 45;
		}
		else if (get_property("_questPirateRealm") == "step7") {
			garbo_turns -= 25;
		}
		else {
			print("Unknown amount of time needed for PirateRealm", "red");
			print("Erring on the side of more than less", "red");
			print("_questPirateRealm value: " + get_property("_questPirateRealm"), "red");
		}
	}

	// CyberRealm
	if (get_property("_khl_realm_cr").to_boolean()) {
		garbo_turns -= 47;
	}


	// Setup - Properties
	if (!get_property("_variables_initialized").to_boolean()) {
		setProperties();
	}

	secondBreakfast();
	runChibi();

	if (!get_property("_autogarboran").to_boolean()) {
		try {
			cli_execute("git update");
		}
		finally {
			runGarbo(garbo_turns, false, true);
			set_property("_autogarboran", true);
		}
	}
	hackTheWorld();
	runFr();
	runLtt();
	runPr();

	// cleanup, put stuff away
	stashHandler("put", stash_clan, social_clan);
	runReports();
}