/datum/BSQL_Connection
	var/id
	var/connection_type

BSQL_PROTECT_DATUM(/datum/BSQL_Connection)

/datum/BSQL_Connection/New(connection_type)
	src.connection_type = connection_type

	if(!world._BSQL_Initialized())
		var/result = world._BSQL_Internal_Call("Initialize")
		if(result)
			BSQL_ERROR(result)
			return
		world._BSQL_Initialized(TRUE)

	var/error = world._BSQL_Internal_Call("CreateConnection", connection_type)
	if(error)
		BSQL_ERROR(error)
		return

	id = world._BSQL_Internal_Call("GetConnection")
	if(!id)
		BSQL_ERROR("BSQL library failed to provide connect operation for connection id [id]([connection_type])!")

BSQL_DEL_PROC(/datum/BSQL_Connection)
	var/error
	if(id)
		error = world._BSQL_Internal_Call("ReleaseConnection", id)
	. = ..()
	if(error)
		BSQL_ERROR(error)

/datum/BSQL_Connection/BeginConnect(ipaddress, port, username, password)
	var/error = world._BSQL_Internal_Call("OpenConnection", id, ipaddress, "[port]", username, password)
	if(error)
		BSQL_ERROR(error)
		return

	var/op_id = world._BSQL_Internal_Call("GetOperation")
	if(!op_id)
		BSQL_ERROR("Library failed to provide connect operation for connection id [id]([connection_type])!")
		return

	return new /datum/BSQL_Operation(src, op_id)


/datum/BSQL_Connection/BeginQuery(query)
	var/error = world._BSQL_Internal_Call("NewQuery", id, query)
	if(error)
		BSQL_ERROR(error)
		return

	var/op_id = world._BSQL_Internal_Call("GetOperation")
	if(!op_id)
		BSQL_ERROR("Library failed to provide query operation for connection id [id]([connection_type])!")
		return

	return new /datum/BSQL_Operation/Query(src, op_id)