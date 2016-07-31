;Author : Chris Migut
;	: This system was based on report system for my fleet.  
;	: It was seen a something that my fleet could use with the multiple different reports they have created
;	: 	and help mange fleet resources.
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;ERROR Handling: If user has missed typed input, it is also assumed they had missed type input before in the system.
;SOLUTION      : FUll system reset. (If this was a different language, I could count on try-catches and such to 
;					handle such errors.) 
;#################################################################################################################
; Class Object
;-----------------------------------------------------------------------------------------------------------------
; Person Objects
;=================================================================================================================
; | Member: Can create only incident reports and view the report they created. (OF-1, OF-2)
; | Admin : Can create incident and transfer reports and view logs/ suggestion files (OF-3,..., OF-7)
(defclass MEMBER
	(is-a USER)
	(role concrete)
	(multislot username (type SYMBOL))
	(slot rank (type SYMBOL))
	(slot permission (type INTEGER) (default 0))) 

(defclass ADMIN
	(is-a MEMBER)
	(slot role))

;-----------------------------------------------------------------------------------------------------------------
; Report Objects
;-----------------------------------------------------------------------------------------------------------------
(defclass REPORT 
	(is-a USER)
	(role concrete)
	(slot timestamp))

(defclass LOGGER_REPORT 
	(is-a REPORT)
	(role concrete)
	(slot called-from)
	(slot username)
	(slot message)
	(message-handler write-to-log)
	(message-handler read-log))

(defclass INCIDENT_REPORT 
	(is-a REPORT)
	(role concrete)
	(slot incident_type)
	(slot repeated_offense)
	(slot isdocumentation_of_proof)
	(slot incident_level)
	(slot offender_name)
	(slot suggested_outcome)
	(message-handler write-outcome-to-file)
	(message-handler read-outcome-to-file))

(defclass TRANSFER_REPORT
	(is-a REPORT)
	(slot commanding-officer)
	(slot person-being-transferd)
	(slot reason-for-transfer)
	(message-handler write-transfer-to-file)
	(message-handler read-transfer-to-file))


;=================================================================================================================
;#################################################################################################################
; Message-Handler
;=================================================================================================================   
;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: read-outcome-to-file
; |	INPUT : Read the whole log file -> "Transfer_File.txt"		
; |	OUTPUT: Display the transfer file to terminal	
; |
; | GOAL: Stated by fleet admins, this could be used to keep track of merging of battlegroups
;*****************************************************************************************************************
(defmessage-handler TRANSFER_REPORT read-transfer-to-file before ()
	(printout t "*** Starting to read transfer file *** " crlf))

(defmessage-handler TRANSFER_REPORT read-transfer-to-file ()
	(open "Transfer_File.txt" rdtranfile)
		(bind ?data (readline rdtranfile))
		(while (neq ?data EOF)
			(printout t ?data)
			(printout t crlf)
			(bind ?data (readline rdtranfile))
		)
	(close rdtranfile)
)

(defmessage-handler TRANSFER_REPORT read-transfer-to-file after ()
	(printout t "*** Done reading from transfer file... *** " crlf crlf))

;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: write-transfer-to-file
; |	INPUT : Caller function provides information to write to logfile		
; |	OUTPUT: The write log to external logfile -> "CLIPS_LOG_FILE.txt"	
; |
; | GOAL: Logs can be used for debugging the system
;*****************************************************************************************************************
(defmessage-handler TRANSFER_REPORT write-transfer-to-file before ()
	(printout t "*** Writing to transfer file: " crlf))

(defmessage-handler TRANSFER_REPORT write-transfer-to-file ()
	(open "Transfer_File.txt" transfer_file "a")
		(printout transfer_file "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
		(printout transfer_file "[TRANSFER REPORT] " crlf)
		(printout transfer_file "------------------------------------------------------" crlf)
		(printout transfer_file "Timestamp           : " (send [logger] get-timestamp) crlf)
		(printout transfer_file "Report Owner        : " (send [logger] get-username) crlf)
		(printout transfer_file "Transfer            : " ?self:person-being-transferd crlf)
		(printout transfer_file "Commanding Officer  : " ?self:commanding-officer crlf)
		(printout transfer_file "Reason for transfer : " ?self:reason-for-transfer crlf)
		(printout transfer_file "------------------------------------------------------" crlf)

	(close transfer_file)
)

(defmessage-handler TRANSFER_REPORT write-transfer-to-file after ()
	(printout t "*** Done writing to transfer file..." crlf crlf))


;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: write-outcome-to-file
; |	INPUT : Caller function provides information to write to outcome file		
; |	OUTPUT: The write log to external outcome file -> "Suggestion_File.txt"	
; |
; | GOAL: Suggestion file keeps track of all suggestion built by the systm relating to incident reports
;*****************************************************************************************************************
(defmessage-handler INCIDENT_REPORT write-outcome-to-file before ()
	(printout t "*** Writing to suggestion file: " crlf))

(defmessage-handler INCIDENT_REPORT write-outcome-to-file ()
	(open "Suggestion_File.txt" suggest_file "a")
		(printout suggest_file "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
		(printout suggest_file "[INCIDENT REPORT] " crlf)
		(printout suggest_file "------------------------------------------------------" crlf)
		(printout suggest_file "Timestamp        : " (send [logger] get-timestamp) crlf)
		(printout suggest_file "Report Owner     : " (send [logger] get-username) crlf)
		(printout suggest_file "Offender Name    : " ?self:offender_name crlf)
		(printout suggest_file "Incident Type    : " ?self:incident_type crlf)
		(printout suggest_file "Repeated Offense : " ?self:repeated_offense crlf)
		(printout suggest_file "Incident Level   : " ?self:incident_level crlf)
		(printout suggest_file "------------------------------------------------------" crlf)
		(printout suggest_file "Suggested Outcome: " ?self:suggested_outcome crlf)
	(close suggest_file)
)

(defmessage-handler INCIDENT_REPORT write-outcome-to-file after ()
	(printout t "*** Done writing to suggestion file..." crlf crlf))

;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: read-outcome-to-file
; |	INPUT : Read the whole suggestion -> "Suggestion_File.txt"		
; |	OUTPUT: Display the suggestion file to terminal	
; |
; | GOAL: LSuggestion file keeps track of all suggestion built by the systm relating to incident reports
;*****************************************************************************************************************
(defmessage-handler INCIDENT_REPORT read-outcome-to-file before ()
	(printout t "*** Starting to read suggestion file *** " crlf))

(defmessage-handler INCIDENT_REPORT read-outcome-to-file ()
	(open "Suggestion_File.txt" rdfile)
		(bind ?data (readline rdfile))
		(while (neq ?data EOF)
			(printout t ?data)
			(printout t crlf)
			(bind ?data (readline rdfile))
		)
	(close rdfile)
)

(defmessage-handler INCIDENT_REPORT read-outcome-to-file after ()
	(printout t "*** Done reading from suggestion file... *** " crlf crlf))

;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: write-to-log
; |	INPUT : Caller function provides information to write to logfile		
; |	OUTPUT: The write log to external logfile -> "CLIPS_LOG_FILE.txt"	
; |
; | GOAL: Logs can be used for debugging the system
;*****************************************************************************************************************
(defmessage-handler LOGGER_REPORT write-to-log before ()
	(printout t "*** Writing to log: " crlf ?self:message crlf))

(defmessage-handler LOGGER_REPORT write-to-log ()
	(open "CLIPS_LOG_FILE.txt" logfile "a")
		(printout logfile "------------------------------------------------------" crlf)
		(printout logfile "Timestamp      : " (send [logger] get-timestamp) crlf)
		(printout logfile "Called from    : " ?self:called-from crlf)
		(printout logfile "Username       : " ?self:username crlf)
		(printout logfile "System Message : " ?self:message crlf)
	(close logfile)
)

(defmessage-handler LOGGER_REPORT write-to-log after ()
	(printout t "*** Done writing to log..." crlf crlf))

;*****************************************************************************************************************
; | MESSAGE-HANDLER NAME: read-log
; |	INPUT : Read the whole log file -> "CLIPS_LOG_FILE.txt"		
; |	OUTPUT: Display the logfile to terminal	
; |
; | GOAL: Logs can be used for debugging the system
; | NOTE: I hate loops/reading file in CLIPS, lack of good documents on the subject
;*****************************************************************************************************************
(defmessage-handler LOGGER_REPORT read-log before ()
	(printout t "*** Starting to read log file *** " crlf))

(defmessage-handler LOGGER_REPORT read-log ()
	(open "CLIPS_LOG_FILE.txt" logfile)
		(bind ?data (readline logfile))
		(while (neq ?data EOF)
			(printout t ?data)
			(printout t crlf)
			(bind ?data (readline logfile))
		)
	(close logfile)
)

(defmessage-handler LOGGER_REPORT read-log after ()
	(printout t "*** Done reading from log file... *** " crlf crlf))

;=================================================================================================================
;#################################################################################################################
; Functions
;=================================================================================================================   
;  [Check-User-Functions] 
;================================================================================================================= 
;*****************************************************************************************************************
; | FUNCTION NAME: check-user-permissions
; |	INPUT : Rank of the user entered at started of program		
; |	OUTPUT: 	*IF user-rank = Officer rank, then return 1
; |			*IF user-rank < Officer rank, then return 0 
; |
; | GOAL: Basic authentication of user permissions
;*****************************************************************************************************************
(deffunction check-user-permissions 
	(?user-rank)
	(send [logger] put-called-from check-user-permissions)
	(send [logger] put-message "---> Checking user's permissions...")
	(switch ?user-rank
		;--------------------------------------
		;|Non-Officer permission check|
		;--------------------------------------
		(case OF-1 then (bind ?return-value 0))
		(case OF-2 then (bind ?return-value 0))
		;--------------------------------------
		;|Officer permission check|
		;--------------------------------------
		(case OF-3 then (bind ?return-value 1))
		(case OF-4 then (bind ?return-value 1))
		(case OF-5 then (bind ?return-value 1))
		(case OF-6 then (bind ?return-value 1))
		(case OF-7 then (bind ?return-value 1))
		;--------------------------------------
		;|ERROR: Invalid Permission Status |
		;--------------------------------------
		(default (bind ?return-value -1))
	)
	(return ?return-value)
)
;*****************************************************************************************************************
; | FUNCTION NAME: update-permissions
; |	INPUT : Current permission level of user		
; |	OUTPUT: Depending on permission level, 
; |		   Either retract & assert user of higher permissions
; |		   <Currently only applies to officers>
; |		   -OR-
; |		   Keep current user of same permission
; |			
; | GOAL: Update current user permissions if required
;*****************************************************************************************************************
(deffunction update-permissions
	(?user-permission)
	(switch ?user-permission
		(case 1 then
			(send [logger] put-called-from check-user-permissions)
			(send [logger] put-message "---> Updating user permissions... Privilege escalation to admin.")
			(send [logger] write-to-log)
			(make-instance admin of ADMIN
			(username (send [member] get-username))
			(rank (send [member] get-rank))
			(permission (send [member] get-permission)))
		      	(unmake-instance member)
			(assert (admin-is-created)))

		(case -1 then
			(send [logger] put-called-from check-user-permissions)
			(send [logger] put-message "---> Updating user permissions... Invalid user. Removing user.")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID USER." crlf)
			(printout t "NOTE    : You entered an invalid rank (or) format for user." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset))
	)
)
;-----------------------------------------------------------------------------------------------------------------
;=================================================================================================================   
;   [System-Functions] 
;=================================================================================================================
;***************************************************************************************************************** 
; | FUNCTION NAME: get-system-time
; |	INPUT : Which datetime object should be returned
; |			-> "date /t": DateSym mm/dd/yyyy
; |			-> "time /t": hh:mm period	
; |	OUTPUT: Based on the supplied format for date object, 
; |		     	The expected value will be returned.
; |			
; | GOAL: Return sytem-time for logger.
; | Note: The following code is based on the following link:
; | URL: http://sourceforge.net/p/clipsrules/discussion/776946/thread/bfa;a10cb/
;***************************************************************************************************************** 
(deffunction get-system-time (?time-format)
	(bind ?time-format(str-cat ?time-format "> SysTime.txt"))
	(system ?time-format)
	(open "SysTime.txt" logfile "r")
		(bind ?val (readline logfile))
	(close logfile)
	return ?val
)
;*****************************************************************************************************************
; | FUNCTION NAME: description-system-info
; |	INPUT : NONE
; |	OUTPUT: Display text to terminal relating to documentation of the expert system
; |			
; | GOAL: Display the following to the user: 
; |		-> System Description
; |		-> How the system works
; |		-> What infomation the system will return
;*****************************************************************************************************************
(deffunction description-system-info ()
	(printout t "******************************" crlf)
	(printout t "Statement of Purpose: " crlf)
	(printout t "------------------------------" crlf)
	(printout t "  The goal of this expert system is to recommendation course of actions relating to " crlf)
	(printout t "  based on the type of report submitted. The permission level of the user " crlf)
	(printout t "  will determin which reports the user can view. " crlf)
	(printout t "  The primary purpose of the system was created for Systems United Navy (SUN)" crlf)
	(printout t "  incident reporting. This system is built as a testbed to see what CLIPS can do. " crlf)
	(printout t "  If the system proves to be somewhat useful, there is an addons that allows CLIPS " crlf)
	(printout t "  code to be used with ptyhon. " crlf crlf)
	(printout t "******************************" crlf)

	(printout t "System Description : " crlf)
	(printout t "------------------------------" crlf)
	(printout t "  This is a forward-chaining expert system using CLIPS. " crlf)
	(printout t "  Foward-chaining takes a series of facts given to return a finial result. " crlf)
	(printout t "  The facts are provided by the user as enter input or from a file. " crlf)
	(printout t "  In this system will be expecting the user to enter input into the terminal." crlf crlf)

	(printout t "******************************" crlf)
	(printout t "How the System works : " crlf) 
	(printout t "------------------------------" crlf)
	(printout t "  The system will ask the user a series of questions." crlf)
	(printout t "  Based on those questions, the user will be able to access different" crlf)
	(printout t "  functions relating to the sytem based on their permission level. " crlf)
	(printout t "  For example, an officer of the fleet will have access to more reports " crlf)
	(printout t "  then that of a non-officer. We assume that an officer is an admin in general. " crlf)
	(printout t "  Upon the final question asked by the system, will return a result. " crlf)
	(printout t "******************************" crlf)
	(printout t "NOTE: OF-1 and OF-2 = normal member, while OF-3,..., OF-7 = admin" crlf) 
	(printout t "==============================" crlf)
)
;=================================================================================================================   
;   [Report-Functions] 
;=================================================================================================================
;***************************************************************************************************************** 
; | FUNCTION NAME: create-new-report
; |	INPUT : Depending on which option the user picked for report type
; |			that report type will be created. 
; |		-> IF '1' is supplied, then a new INCIDENT_REPORT is created.
; |	OUTPUT: Create a new report instance of the chosen type by the user
; |			
; | GOAL: By having the creation of reports within a function, 
; | 		new report types can be added without much change to other parts of the code.
;***************************************************************************************************************** 
(deffunction create-new-report 
	(?report-type)
	(switch ?report-type
		(case 1 then
			(send [logger] put-called-from create-new-report)
			(send [logger] put-message "--> Creating a new INCIDENT_REPORT. ")
			(send [logger] write-to-log)
			(make-instance incident-report of INCIDENT_REPORT))
		(case 2 then
			(send [logger] put-called-from create-new-report)
			(send [logger] put-message "--> Creating a new TRANSFER_REPORT. ")
			(send [logger] write-to-log)
			(assert (create-transfer-report-true))
			(make-instance transfer-report of TRANSFER_REPORT))
		(default 
			(send [logger] put-called-from create-new-report)
			(send [logger] put-message "---> Fail to Create user's report... system restart")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID REPORT TYPE." crlf)
			(printout t "NOTE    : System can not create report which does not have." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset))
	)
)

;-----------------------------------------------------------------------------------------------------------------
;=================================================================================================================   
;   [Rules] 
;=================================================================================================================
;*****************************************************************************************************************
; | RULE NAME  : show-system-description 
; |	FACTS  : None
; |	RESULTS: Display the description of the expert system to the user
; |	
; |	RULE NUMBER: 1 								
;*****************************************************************************************************************
(defrule show-system-description (declare(salience 20))
=>
	(description-system-info)
	(assert (description-shown))
)

;*****************************************************************************************************************
; | RULE NAME  : create-user
; |	FACTS  : (description-shown) if the show-system-description has been succuessful in display
; |			Then it should be assumed that the system can coutiune.
; |	RESULTS: Create a new member based on the information provided by the user.
; |	
; |	RULE NUMBER: 2 								
;*****************************************************************************************************************
(defrule create-user 
	(description-shown)
=>
	(printout t crlf "Starting System..." crlf)
	(printout t "------------------------------" crlf)
	(printout t "What is your username ? " crlf )
	(printout t "> ")
	(bind ?username (readline))
	(printout t "------------------------------" crlf)
	(printout t "What is your rank ? " crlf)
	(printout t "[Allowed format: OF-1, OF-2,..., OF-7]" crlf)
	(printout t "> ")
	(bind ?rank(read))
	(printout t "------------------------------" crlf)
	(assert (user-is-created))
	(make-instance logger of LOGGER_REPORT)
	(make-instance member of MEMBER
		(username ?username)
		(rank ?rank))
	(send [logger] put-timestamp (str-cat (get-system-time "date /t") " : " (get-system-time "time /t")))
	(send [logger] put-called-from create-user)
	(send [logger] put-username ?username)
	(send [logger] put-message (str-cat "---> Basic user is created: " ?username "  "))
	(send [logger] write-to-log)	
	
)

;*****************************************************************************************************************
; | RULE NAME  : check-permission
; |	FACTS  : (user-is-created) only happens of member has been created
; |	RESULTS: Based on member's rank normalize them to either
; | 			officer = 1 or non-officer = 0
; |	
; |	RULE NUMBER: 3 								
;*****************************************************************************************************************
(defrule check-permission (declare(salience 5))
	(user-is-created)
=>
(send [member] put-permission (check-user-permissions (send [member] get-rank))))

;*****************************************************************************************************************
; | RULE NAME  : update-permissions
; |	FACTS  : (user-is-created) only happens of member has been created
; |	RESULTS: Based on their the normilzed permission, 
; |			update the member status to admin if they are an officer  
; |	
; |	RULE NUMBER: 4 								
;*****************************************************************************************************************
(defrule update-permissions 
	(user-is-created)
=>
	(update-permissions (send [member] get-permission))
	(assert (permission-check-done)))

;*****************************************************************************************************************
; | RULE NAME  : if-admin-remove-basic-user
; |	FACTS  : (admin-is-created) 
; |	RESULTS: If user is an admin, they are no longer a basic user. Remove basic user. 
; |	
; |	RULE NUMBER: 5 								
;*****************************************************************************************************************
(defrule if-admin-remove-basic-user (declare(salience 1))
	(admin-is-created)
	?user <- (user-is-created)
=>
	(retract ?user)
	(send [admin] put-role "system-admin")
)
;*****************************************************************************************************************
; | RULE NAME  : display-options-admin
; |	FACTS  : (permission-check-done) and if user is an admin 
; |	RESULTS: Display options to create an INCIDENT_REPORT and view logs.  
; |	
; |	RULE NUMBER: 6 								
;*****************************************************************************************************************
(defrule display-options-admin
	(permission-check-done)
	(admin-is-created)
	?admin <- (admin-is-created)
=>
	(make-instance transfer-list of TRANSFER_REPORT)
	(printout t "Hello admin, please select an option below :" crlf)
	(printout t "------------------------------" crlf)
	(printout t "[1] INCIDENT_REPORT" crlf)
	(printout t "[2] TRANSFER_REPORT" crlf)
	(printout t "[3] VIEW LOGS" crlf)
	(printout t "[4] VIEW TRANSFERS" crlf)
	(printout t "[5] RESET SYSTEM" crlf)
	(printout t "------------------------------" crlf)
	(printout t "[Type Integer value]" crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "------------------------------" crlf)
	(switch ?option
		(case 1 then
			(create-new-report ?option))
		(case 2 then 
			(create-new-report ?option))
		(case 3 then 
			(send [logger] read-log)
			(retract ?admin)
			(assert (admin-is-created)))
		(case 4 then 
			(send [transfer-list] read-transfer-to-file)
			(retract ?admin)
			(assert (admin-is-created))
			(assert (display-transfers)))
		(case 5 then
			(reset))
		(default
			(send [logger] put-called-from display-options-admin)
			(send [logger] put-message "---> Invaild admin command... system restart")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID ADMIN COMMAND ENTERED." crlf)
			(printout t "NOTE    : System can not act on invalid admin command." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset))
	)
)

;*****************************************************************************************************************
; | RULE NAME  : display-options-member
; |	FACTS  : (permission-check-done) and if user is still member 
; |	RESULTS: Display only option to create an INCIDENT_REPORT to member.  
; |	
; |	RULE NUMBER: 7 								
;*****************************************************************************************************************
(defrule display-options-member
	(permission-check-done)
	(user-is-created)
=>
	(printout "Hello member, would you like to create of the following :" crlf)
	(printout t "------------------------------" crlf)
	(printout t "[1] INCIDENT_REPORT" crlf)
	(printout t "------------------------------" crlf)
	(printout t "[Type Integer value]" crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "------------------------------" crlf)
	(create-new-report ?option)
)


;*****************************************************************************************************************
; | RULE NAME  : read-log-file
; |	FACTS  : (read-logs-true)
; |	RESULTS: Display the records of the log file onto the terminal for the admin.   
; |	
; |	RULE NUMBER: 8								
;*****************************************************************************************************************
(defrule read-log-file
 	(read-logs-true)
=>
	(send [logger] read-log)
)
;*****************************************************************************************************************
; | RULE NAME  : proof-provided-for-incident-report 
; |	FACTS  : An instance of INCIDENT_REPORT has to been already created.
; |	RESULTS: If no proof can be provided by the user, then an incident-report should not contiune.   
; |	
; |	RULE NUMBER: 9								
;*****************************************************************************************************************
(defrule proof-provided-for-incident-report
 	?o <- (object (is-a INCIDENT_REPORT))
=>
	(printout t crlf "Incident Reporting:" crlf)
	(printout t "Was there any document proof of the incident to be reported?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "Answer: ( Y / N )" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?answer (read))
	(switch ?answer 
		(case Y then
			(send [incident-report] put-isdocumentation_of_proof true)
			(send [incident-report] put-timestamp (str-cat (get-system-time "date /t") " : " (get-system-time "time /t")))
			(assert (document-proof-true))

			(send [logger] put-called-from proof-provided-for-incident-report)
			(send [logger] put-message "---> Documented proof of incident: true")
			(send [logger] write-to-log)
		)
		(case N then 
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "------------------------------------------------------------" crlf)
			(printout t "Sorry, without documented proof as stated in handbook" crlf
					" the incident will have to be dropped. " crlf crlf)

			(send [logger] put-called-from proof-provided-for-incident-report)
			(send [logger] put-message "---> Documented proof of incident: false. System exit.")
			(send [logger] write-to-log)
			
		)
		(default
			(send [logger] put-called-from proof-provided-for-incident-report)
			(send [logger] put-message "---> Invaild command... system restart")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID COMMAND ENTERED." crlf)
			(printout t "NOTE    : System can not act on invalid command." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset)))
)
;*****************************************************************************************************************
; | RULE NAME  : incident-type-for-incident-report 
; |	FACTS  : (document-proof-true) then there is a vaild incident
; |	RESULTS: Determine which type of incident the user is reporting   
; |	
; |	RULE NUMBER: 10								
;*****************************************************************************************************************
(defrule incident-type-for-incident-report 
	?o <- (object (is-a INCIDENT_REPORT))
 	(document-proof-true)
=>
	(printout t crlf "Incident Reporting:" crlf)
	(printout t "What type of incident are you reporting?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "[1] Disrespect" crlf)
	(printout t "[2] Discrimination" crlf)
	(printout t "[3] Disrepute" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "------------------------------------------------------------" crlf)
	(switch ?option 
		(case 1 then 
			(send [incident-report] put-incident_type Disrespect )
			(assert (incident_type-filled))

			(send [logger] put-called-from "incident-type-for-incident-report" )
			(send [logger] put-message "---> Incident type reported: Disrespect")
			(send [logger] write-to-log)
		)
		(case 2 then 
			(send [incident-report] put-incident_type Discrimination)
			(assert (incident_type-filled))

			(send [logger] put-called-from "incident-type-for-incident-report" )
			(send [logger] put-message "---> Incident type reported: Discrimination")
			(send [logger] write-to-log)
		)
		(case 3 then 
			(send [incident-report] put-incident_type Disrepute)
			(assert (incident_type-filled))

			(send [logger] put-called-from "incident-type-for-incident-report" )
			(send [logger] put-message "---> Incident type reported: Disrepute")
			(send [logger] write-to-log)
		)
		(default
			(send [logger] put-called-from "incident-type-for-incident-report" )
			(send [logger] put-message "---> Invaild incident type... system restart")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID INCIDENT ENTERED." crlf)
			(printout t "NOTE    : Only Incidents from the above list will be checked." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset)))
)
;*****************************************************************************************************************
; | RULE NAME  : repeated_offense-incident-report 
; |	FACTS  : (document-proof-true) then there is a vaild incident
; |	RESULTS: Determine of this was a repeated offense   
; |	
; |	RULE NUMBER: 11								
;*****************************************************************************************************************
(defrule repeated_offense-incident-report 
	?o <- (object (is-a INCIDENT_REPORT))
 	(document-proof-true)
=>
	(printout t crlf "Incident Reporting:" crlf)
	(printout t "Has there been multiple cases of this type ofconduct of the offerder?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "Answer: ( Y / N )" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?answer (read))
	(printout t "--------------------------------------------------------------------" crlf)
	(switch ?answer 
		(case Y then 
			(send [incident-report] put-repeated_offense true )
			(assert (repeated_offense-true))

			(send [logger] put-called-from "repeated_offense-incident-report " )
			(send [logger] put-message "---> This has been a multiple offenses of this type agasist the offender")
			(send [logger] write-to-log)
		)
		(case N then
			(send [incident-report] put-repeated_offense false )
			(assert (repeated_offense-false))

			(send [logger] put-called-from "repeated_offense-incident-report " )
			(send [logger] put-message "---> First time this offense has been reported agasint the offender")
			(send [logger] write-to-log)
		)
		(default
			(send [logger] put-called-from "repeated_offense-incident-report" )
			(send [logger] put-message "---> Invaild input ... system restart")
			(send [logger] write-to-log)
			(printout t "===========================================================" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "ERROR   : NOT A VALID ANSWER ENTERED." crlf)
			(printout t "NOTE    : Only Selection from the above list will be checked." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "SOLUTION: SYSTEM RESET..." crlf)
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" crlf)
			(reset)))
)

;*****************************************************************************************************************
; | RULE NAME  : offender-name-incident-report 
; |	FACTS  : (document-proof-true) then there is a vaild incident
; |	RESULTS: Attach to the incident report whom the report is agasint   
; |	
; |	RULE NUMBER: 12								
;*****************************************************************************************************************
(defrule offender-name-incident-report 
	(document-proof-true)
=>
	(printout t crlf "Incident Reporting:" crlf)
	(printout t "What is the name of the offerder of the incident?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?offender (readline))
	(printout t "------------------------------------------------------------" crlf)
	(send [incident-report] put-offender_name ?offender)

	(send [logger] put-called-from offender-name-incident-report )
	(send [logger] put-message "---> User has provided the name of the offender of the incident?")
	(send [logger] write-to-log)
)

;*****************************************************************************************************************
; | RULE NAME  : incident-level-incident-report 
; |	FACTS  : (document-proof-true) then there is a vaild incident
; |	RESULTS: Determine how severe the incident is based on number of factors.
; |			-> If repeated_offense and offense type
; |		 There are 4 levels of incident-levels:
; |		 * [low , med, high] 
; |	
; |	RULE NUMBER: 13							
;*****************************************************************************************************************
(defrule incident-level-incident-report (declare(salience -10))
	?o <- (object (is-a INCIDENT_REPORT))
	(document-proof-true)
=>
	(printout t "Processing incident-level..." crlf)
	(switch (send ?o get-incident_type)
		(case Disrespect then 
			(switch (send ?o get-repeated_offense)
				(case true then
					(bind ?level med)
				)
				(case false then
					(bind ?level low)
				)
			)
		)
		(case Discrimination then
			(switch (send ?o get-repeated_offense)
				(case true then
					(bind ?level high)
				)
				(case false then
					(bind ?level med)
				)	
			)
		)
		(case Disrepute then
			(switch (send ?o get-repeated_offense)
				(case true then
					(bind ?level med)
				)
				(case false then
					(bind ?level low)
				)
			)
		)
	)
	(send [incident-report] put-incident_level ?level)
	(send [logger] put-called-from "incident-level-incident-report" )
	(send [logger] put-message "---> Based on following factors (incident_type & repeated_offense)...incident-level calculated.")
	(send [logger] write-to-log)
	(assert (suggest-outcome))
)

;*****************************************************************************************************************
; | RULE NAME  : suggest-outcome 
; |	FACTS  : (suggest-outcome) then facts of incident has been processed
; |	RESULTS: Suggest outcome relating incident_level from the incident report. 
; |			Save to outcome file.
; |	
; |	RULE NUMBER: 14							
;*****************************************************************************************************************
(defrule suggest-outcome
	?o <- (object (is-a INCIDENT_REPORT))
	(suggest-outcome)
=>
	(printout t "Processing suggest-outcome..." crlf)
	(switch (send ?o get-incident_level)
		(case low then 
			(send [incident-report] put-suggested_outcome "informal warning")
		)
		(case med then
			(send [incident-report] put-suggested_outcome "written warning")
		)
		(case high then
			(send [incident-report] put-suggested_outcome "remove from fleet")
		)
	)			
	(send [incident-report] write-outcome-to-file)
	(assert (suggestion-saved))
	
	(send [logger] put-called-from suggest-outcome)
	(send [logger] put-message "--> System suggesting outcome... ")
	(send [logger] write-to-log)
)

;*****************************************************************************************************************
; | RULE NAME  : display-suggestion-to-user 
; |	FACTS  : (suggestion-saved) then facts of incident has been processed
; |	RESULTS: Ask if basic user would like to see the results 
; |	
; |	RULE NUMBER: 15						
;*****************************************************************************************************************
(defrule display-suggestion-to-user
	?o <- (object (is-a INCIDENT_REPORT))
	?suggestion <- (suggestion-saved)
	(user-is-created)
	(suggestion-saved)
=>
	(printout t crlf "Suggestion Processed:" crlf)
	(printout t "Would you like to see the suggestion created by system?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "Answer: ( Y / N )" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?answer (read))
	(printout t "--------------------------------------------------------------------" crlf)
	(switch ?answer 
		(case Y then 
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
			(printout t "[INCIDENT REPORT] " crlf)
			(printout t "------------------------------------------------------" crlf)
			(printout t "Timestamp        : " (send [logger] get-timestamp) crlf)
			(printout t "Report Owner     : " (send [logger] get-username) crlf)
			(printout t "Offender Name    : " (send [incident-report] get-offender_name) crlf)
			(printout t "Incident Type    : " (send [incident-report] get-incident_type) crlf)
			(printout t "Repeated Offense : " (send [incident-report] get-repeated_offense) crlf)
			(printout t "Incident Level   : " (send [incident-report] get-incident_level) crlf)
			(printout t "------------------------------------------------------" crlf)
			(printout t "Suggested Outcome: " (send [incident-report] get-suggested_outcome) crlf)
			(printout t "--------------------------------------------------------------------" crlf)
			(printout t "Thank you for your incident report." crlf) 
		)
		(case N then
			(printout t "Thank you for your incident report." crlf)
			
		)
		(default 
			(retract ?suggestion)
			(assert (suggestion-saved)))
	)
	(assert (incident-report-done))
		
)

;*****************************************************************************************************************
; | RULE NAME  : display-suggestion-to-admin 
; |	FACTS  : (suggestion-saved) then facts of incident has been processed
; |	RESULTS: Ask if admin user would like to see the results 
; |	
; |	RULE NUMBER: 16						
;*****************************************************************************************************************
(defrule display-suggestion-to-admin
	?o <- (object (is-a INCIDENT_REPORT))
	?suggestion <- (suggestion-saved)
	(admin-is-created)
	(suggestion-saved)
=>
	(printout t crlf "Suggestion Processed:" crlf)
	(printout t "Would you like to see the suggestion created by system?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "Answer: ( Y / N )" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?answer (read))
	(printout t "--------------------------------------------------------------------" crlf)
	(switch ?answer 
		(case Y then 
			(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" 				crlf)
			(printout t "[INCIDENT REPORT] " 								crlf)
			(printout t "------------------------------------------------------" 				crlf)
			(printout t "Timestamp        : " (send [logger] get-timestamp)					crlf)
			(printout t "Report Owner     : " (send [logger] get-username) 					crlf)
			(printout t "Offender Name    : " (send [incident-report] get-offender_name) 			crlf)
			(printout t "Incident Type    : " (send [incident-report] get-incident_type) 			crlf)
			(printout t "Repeated Offense : " (send [incident-report] get-repeated_offense) 		crlf)
			(printout t "Incident Level   : " (send [incident-report] get-incident_level) 			crlf)
			(printout t "------------------------------------------------------" 				crlf)
			(printout t "Suggested Outcome: " (send [incident-report] get-suggested_outcome) 	   crlf	crlf)
			(printout t "------------------------------------------------------" 				crlf)
			
			(printout t "Would you like review all incident reports?" 					crlf)
			(printout t "------------------------------------------------------------" 			crlf)
			(printout t "Answer: ( Y / N )" 								crlf)
			(printout t "------------------------------------------------------------" 			crlf)
			(printout t "> ")
			(bind ?option (read))
			(printout t "--------------------------------------------------------------------" 		crlf)
			(switch ?option
				(case Y then 
					(send [incident-report] read-outcome-to-file)
				)
				(case N then
					(printout t "Thank you for your report." crlf)
					
				)
			))			
			
		(case N then
			(printout t "Thank you for your incident report." crlf) 
			
		)
		(default 
			(retract ?suggestion)
			(assert (suggestion-saved)))
	)
	(assert (incident-report-done))
)
;*****************************************************************************************************************
; | RULE NAME  : restart-system-after-report 
; |	FACTS  : (incident-report-done) the user has finish writing one report 
; |	RESULTS: Ask user if they would like to write a new report. Have to clean system of old facts.  
; |	
; |	RULE NUMBER: 17						
;*****************************************************************************************************************
(defrule restart-system-after-report 
	?report <- (incident-report-done)
	(incident-report-done)
=>
	(printout t crlf "Would you like to write another report? (System restart required)" 		crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "Answer: ( Y / N )" 								crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "--------------------------------------------------------------------" 		crlf)
	(switch ?option
		(case Y then 
			(printout t "System Restart in process.... " crlf crlf)
			(reset)
		)
		(case N then
			(printout t "Goodbye" crlf)
			
		)
		(default
			(retract ?report)
			(assert (incident-report-done))
		)
	)
)
;*****************************************************************************************************************
; | RULE NAME  : set-admin-role 
; |	FACTS  : (admin-is-created) 
; |	RESULTS: Changing the role of the admin could be used later from GM/Network/Fleet admins  
; |	
; |	RULE NUMBER: 18						
;*****************************************************************************************************************		
(defrule set-admin-role (declare(salience 5))
(admin-is-created)

=>
	(printout t crlf "What is your role admin? " crlf)
	(printout t "-----------------------------" crlf)
	(printout t "> " )
	(bind ?role (readline))
	(printout t crlf "-----------------------------" crlf)
	(send [admin] put-role ?role)
	
	(send [logger] put-called-from set-admin-role)
	(send [logger] put-message "--> Changing admin's role... ")
	(send [logger] write-to-log)
)
	
;*****************************************************************************************************************
; | RULE NAME  : reason-for-transfer 
; |	FACTS  : (TRANSFER_REPORT instance created) 
; |	RESULTS: Changing the role of the admin could be used later from GM/Network/Fleet admins  
; |	
; |	GOAL: Allow transfer of a person, but it its because of an incident. Make sure that 
; |		incident was record if the user will allow.
; |	RULE NUMBER: 19						
;*****************************************************************************************************************		
(defrule reason-for-transfer 
?o <- (object (is-a TRANSFER_REPORT))
(create-transfer-report-true)
?ctransfer <- (create-transfer-report-true)
=>
	(send [logger] put-called-from reason-for-transfer)
	(send [logger] put-message "--> Processing resons for transfer... ")
	(send [logger] write-to-log)
	
	(printout t crlf "Transfer Reporting:" crlf)
	(printout t "Why are you filling out transfer report?" crlf)
	(printout t "----------------------------------------" crlf)
	(printout t "> Is the transfer because of an incident with the person being transfered?" crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "Answer: ( Y / N )" 								crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "--------------------------------------------------------------------" 		crlf)
	(switch ?option
		(case Y then
			(printout t crlf "Transfer Reporting:" crlf)
			(printout t crlf "> Is there documentation of an incident report with said person?" crlf)
			(printout t "------------------------------------------------------------" 	crlf)
			(printout t "Answer: ( Y / N )" 						crlf)
			(printout t "------------------------------------------------------------" 	crlf)
			(printout t "> ")
			(bind ?answer(read))
			(printout t "--------------------------------------------------------------------" crlf)
			(switch ?answer
				(case Y then 
					(assert (allow-transfer)))
				(case N then 
					(printout t crlf "Transfer Reporting:" crlf)
					(printout t crlf "> Would you like to create an incident report, instead?" crlf)
					(printout t "------------------------------------------------------------" 	crlf)
					(printout t "Answer: ( Y / N )" 						crlf)
					(printout t "------------------------------------------------------------" 	crlf)
					(printout t "> ")
					(bind ?ans(read))
					(printout t "--------------------------------------------------------------------" crlf)
					(switch ?ans
						(case Y then 
							(retract ?ctransfer)
							(create-new-report 1))
						(case N then 
							(assert (allow-transfer))
							(retract ?ctransfer))
						(default (reset))))
				(default (reset))))

		(case N then 
			(assert (allow-transfer))
		)
		(default (reset))
	)	
)
;*****************************************************************************************************************
; | RULE NAME  : assign-transfer 
; |	FACTS  : (allow-transfer) 
; |	RESULTS: The admin will assign the fields required for transfer. 
; |			These values are saved to transfer file.  
; |	
; |	RULE NUMBER: 20						
;*****************************************************************************************************************		
(defrule assign-transfer 
	;(create-transfer-report-true)
	(allow-transfer)
	?altansfer <- (allow-transfer)
=>
	(printout t crlf "Transfer Reporting:" crlf)
	(printout t "What is the username of the person being transfered?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?transfer (readline))
	(printout t crlf "------------------------------------------------------------" crlf crlf)
	(printout t "Who is the commanding officer of " ?transfer " ?" crlf)
	(printout t "------------------------------------------------------------" crlf)
	(printout t "> ")
	(bind ?commander (readline))
	(printout t crlf "------------------------------------------------------------" crlf)
	(printout t "What is the reason for transfer?" crlf)
	(printout t "> ")
	(bind ?reason (readline))
	(printout t crlf "------------------------------------------------------------" crlf)
	(send [transfer-report] put-commanding-officer ?commander)
	(send [transfer-report] put-person-being-transferd ?transfer)
	(send [transfer-report] put-reason-for-transfer ?reason)
	
	(printout t "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" crlf)
	(printout t "[TRANSFER REPORT] " crlf)
	(printout t "------------------------------------------------------" crlf)
	(printout t "Timestamp           : " (send [logger] get-timestamp) crlf)
	(printout t "Report Owner        : " (send [logger] get-username) crlf)
	(printout t "Transfer            : " (send [transfer-report] get-person-being-transferd) crlf)
	(printout t "Commanding Officer  : " (send [transfer-report] get-commanding-officer) crlf)
	(printout t "Reason for transfer : " (send [transfer-report] get-reason-for-transfer) crlf)
	(printout t "------------------------------------------------------" crlf)

	(send [logger] put-called-from assign-transfer)
	(send [logger] put-message "--> assigning transfer... ")
	(send [logger] write-to-log)

	(retract ?altansfer)

	(send [transfer-report] write-transfer-to-file)

	
	
	(printout t crlf "Would you like to write another report? (System restart required)" 		crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "Answer: ( Y / N )" 								crlf)
	(printout t "------------------------------------------------------------" 			crlf)
	(printout t "> ")
	(bind ?option (read))
	(printout t "--------------------------------------------------------------------" 		crlf)
	(switch ?option
		(case Y then 
			(printout t "System Restart in process.... " crlf crlf)
			(reset)
		)
		(case N then
			(printout t "Goodbye" crlf)
		)
		(default
			(reset)
		)
	)
	
)
;*****************************************************************************************************************
; | RULE NAME  : display-transfer-file 
; |	FACTS  : (display-transfers) 
; |	RESULTS: This will display the list of transfers to terminal   
; |	
; |	RULE NUMBER: 21						
;*****************************************************************************************************************		
;(defrule display-transfer-file 
;	(display-transfers)
;=>
;	(send [transfer-list] read-transfer-to-file)
;)