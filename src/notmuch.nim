##  notmuch - Not much of an email library, (just index and search)
##
##  Copyright © 2009 Carl Worth
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see https://www.gnu.org/licenses/ .
##
##  Author: Carl Worth <cworth@cworth.org>
##
## *
##  @defgroup notmuch The notmuch API
##
##  Not much of an email library, (just index and search)
##
##  @{
##

type
  time_t = int64

##
##  The library version number.  This must agree with the soname
##  version in Makefile.local.
##

const
  LIBNOTMUCH_MAJOR_VERSION* = 5
  LIBNOTMUCH_MINOR_VERSION* = 2
  LIBNOTMUCH_MICRO_VERSION* = 0

## *
##  Check the version of the notmuch library being compiled against.
##
##  Return true if the library being compiled against is of the
##  specified version or above. For example:
##
##  @code
##  #if LIBNOTMUCH_CHECK_VERSION(3, 1, 0)
##      (code requiring libnotmuch 3.1.0 or above)
##  #endif
##  @endcode
##
##  LIBNOTMUCH_CHECK_VERSION has been defined since version 3.1.0; to
##  check for versions prior to that, use:
##
##  @code
##  #if !defined(NOTMUCH_CHECK_VERSION)
##      (code requiring libnotmuch prior to 3.1.0)
##  #endif
##  @endcode
##

template LIBNOTMUCH_CHECK_VERSION*(major, minor, micro: untyped): untyped =
  ( ( LIBNOTMUCH_MAJOR_VERSION > (major) ) or ( LIBNOTMUCH_MAJOR_VERSION == (major) and LIBNOTMUCH_MINOR_VERSION > (minor) ) or ( LIBNOTMUCH_MAJOR_VERSION == (major) and LIBNOTMUCH_MINOR_VERSION == (minor) and LIBNOTMUCH_MICRO_VERSION >= (micro) ) )

## *
##  Notmuch boolean type.
##

type
  notmuch_bool_t* = cint

## *
##  Status codes used for the return values of most functions.
##
##  A zero value (NOTMUCH_STATUS_SUCCESS) indicates that the function
##  completed without error. Any other value indicates an error.
##

type
  notmuch_status_t* {.size: sizeof(cint).} = enum
    NOTMUCH_STATUS_SUCCESS = 0,             ## *
                                            ##  No error occurred.
                                            ##


    NOTMUCH_STATUS_OUT_OF_MEMORY,           ## *
                                            ##  Out of memory.
                                            ##

    NOTMUCH_STATUS_READ_ONLY_DATABASE,      ## *
                                            ##  An attempt was made to write to a database opened in read-only
                                            ##  mode.
                                            ##

    NOTMUCH_STATUS_XAPIAN_EXCEPTION,        ## *
                                            ##  A Xapian exception occurred.
                                            ##
                                            ##  @todo We don't really want to expose this lame XAPIAN_EXCEPTION
                                            ##  value. Instead we should map to things like DATABASE_LOCKED or
                                            ##  whatever.
                                            ##

    NOTMUCH_STATUS_FILE_ERROR,              ## *
                                            ##  An error occurred trying to read or write to a file (this could
                                            ##  be file not found, permission denied, etc.)
                                            ##

    NOTMUCH_STATUS_FILE_NOT_EMAIL,          ## *
                                            ##  A file was presented that doesn't appear to be an email
                                            ##  message.
                                            ##

    NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID,    ## *
                                            ##  A file contains a message ID that is identical to a message
                                            ##  already in the database.
                                            ##

    NOTMUCH_STATUS_NULL_POINTER,            ## *
                                            ##  The user erroneously passed a NULL pointer to a notmuch
                                            ##  function.
                                            ##

    NOTMUCH_STATUS_TAG_TOO_LONG,            ## *
                                            ##  A tag value is too long (exceeds NOTMUCH_TAG_MAX).
                                            ##

    NOTMUCH_STATUS_UNBALANCED_FREEZE_THAW,  ## *
                                            ##  The notmuch_message_thaw function has been called more times
                                            ##  than notmuch_message_freeze.
                                            ##

    NOTMUCH_STATUS_UNBALANCED_ATOMIC,       ## *
                                            ##  notmuch_database_end_atomic has been called more times than
                                            ##  notmuch_database_begin_atomic.
                                            ##

    NOTMUCH_STATUS_UNSUPPORTED_OPERATION,   ## *
                                            ##  The operation is not supported.
                                            ##

    NOTMUCH_STATUS_UPGRADE_REQUIRED,        ## *
                                            ##  The operation requires a database upgrade.
                                            ##

    NOTMUCH_STATUS_PATH_ERROR,              ## *
                                            ##  There is a problem with the proposed path, e.g. a relative path
                                            ##  passed to a function expecting an absolute path.
                                            ##

    NOTMUCH_STATUS_IGNORED,                 ## *
                                            ##  The requested operation was ignored. Depending on the function,
                                            ##  this may not be an actual error.
                                            ##

    NOTMUCH_STATUS_ILLEGAL_ARGUMENT,        ## *
                                            ##  One of the arguments violates the preconditions for the
                                            ##  function, in a way not covered by a more specific argument.
                                            ##

    NOTMUCH_STATUS_MALFORMED_CRYPTO_PROTOCOL,   ## *
                                                ##  A MIME object claimed to have cryptographic protection which
                                                ##  notmuch tried to handle, but the protocol was not specified in
                                                ##  an intelligible way.
                                                ##

    NOTMUCH_STATUS_FAILED_CRYPTO_CONTEXT_CREATION,  ## *
                                                    ##  Notmuch attempted to do crypto processing, but could not
                                                    ##  initialize the engine needed to do so.
                                                    ##

    NOTMUCH_STATUS_UNKNOWN_CRYPTO_PROTOCOL, ## *
                                            ##  A MIME object claimed to have cryptographic protection, and
                                            ##  notmuch attempted to process it, but the specific protocol was
                                            ##  something that notmuch doesn't know how to handle.
                                            ##

    NOTMUCH_STATUS_LAST_STATUS              ## *
                                            ##  Not an actual status value. Just a way to find out how many
                                            ##  valid status values there are.
                                            ##


## *
##  Get a string representation of a notmuch_status_t value.
##
##  The result is read-only.
##

proc status_to_string*(status: notmuch_status_t): cstring {.importc: "notmuch_status_to_string", header: "notmuch.h".}
##  Various opaque data types. For each notmuch_<foo>_t see the various
##  notmuch_<foo> functions below.

type
  notmuch_database_t* = distinct ptr object
  notmuch_query_t* = distinct ptr object
  notmuch_threads_t* = distinct ptr object
  notmuch_thread_t* = distinct ptr object
  notmuch_messages_t* = distinct ptr object
  notmuch_message_t* = distinct ptr object
  notmuch_tags_t* = distinct ptr object
  notmuch_directory_t* = distinct ptr object
  notmuch_filenames_t* = distinct ptr object
  notmuch_config_list_t* = distinct ptr object
  notmuch_indexopts_t* = distinct ptr object

## *
##  Create a new, empty notmuch database located at 'path'.
##
##  The path should be a top-level directory to a collection of
##  plain-text email messages (one message per file). This call will
##  create a new ".notmuch" directory within 'path' where notmuch will
##  store its data.
##
##  After a successful call to notmuch_database_create, the returned
##  database will be open so the caller should call
##  notmuch_database_destroy when finished with it.
##
##  The database will not yet have any data in it
##  (notmuch_database_create itself is a very cheap function). Messages
##  contained within 'path' can be added to the database by calling
##  notmuch_database_index_file.
##
##  In case of any failure, this function returns an error status and
##  sets *database to NULL (after printing an error message on stderr).
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully created the database.
##
##  NOTMUCH_STATUS_NULL_POINTER: The given 'path' argument is NULL.
##
##  NOTMUCH_STATUS_OUT_OF_MEMORY: Out of memory.
##
##  NOTMUCH_STATUS_FILE_ERROR: An error occurred trying to create the
## 	database file (such as permission denied, or file not found,
## 	etc.), or the database already exists.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred.
##

proc create*(path: cstring; database: ptr notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_create", header: "notmuch.h".}
## *
##  Like notmuch_database_create, except optionally return an error
##  message. This message is allocated by malloc and should be freed by
##  the caller.
##

proc create_verbose*(path: cstring; database: ptr notmuch_database_t; error_message: ptr cstring): notmuch_status_t {.importc: "notmuch_database_create_verbose", header: "notmuch.h".}
## *
##  Database open mode for notmuch_database_open.
##

type
  notmuch_database_mode_t* {.size: sizeof(cint).} = enum
    NOTMUCH_DATABASE_MODE_READ_ONLY = 0,    ## *
                                            ##  Open database for reading only.
                                            ##

    NOTMUCH_DATABASE_MODE_READ_WRITE        ## *
                                            ##  Open database for reading and writing.
                                            ##


## *
##  Open an existing notmuch database located at 'path'.
##
##  The database should have been created at some time in the past,
##  (not necessarily by this process), by calling
##  notmuch_database_create with 'path'. By default the database should be
##  opened for reading only. In order to write to the database you need to
##  pass the NOTMUCH_DATABASE_MODE_READ_WRITE mode.
##
##  An existing notmuch database can be identified by the presence of a
##  directory named ".notmuch" below 'path'.
##
##  The caller should call notmuch_database_destroy when finished with
##  this database.
##
##  In case of any failure, this function returns an error status and
##  sets *database to NULL (after printing an error message on stderr).
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully opened the database.
##
##  NOTMUCH_STATUS_NULL_POINTER: The given 'path' argument is NULL.
##
##  NOTMUCH_STATUS_OUT_OF_MEMORY: Out of memory.
##
##  NOTMUCH_STATUS_FILE_ERROR: An error occurred trying to open the
## 	database file (such as permission denied, or file not found,
## 	etc.), or the database version is unknown.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred.
##

proc open*(path: cstring; mode: notmuch_database_mode_t; database: ptr notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_open", header: "notmuch.h".}
## *
##  Like notmuch_database_open, except optionally return an error
##  message. This message is allocated by malloc and should be freed by
##  the caller.
##

proc open_verbose*(path: cstring; mode: notmuch_database_mode_t; database: ptr notmuch_database_t; error_message: ptr cstring): notmuch_status_t {.importc: "notmuch_database_open_verbose", header: "notmuch.h".}
## *
##  Retrieve last status string for given database.
##
##

proc database_status_string*(notmuch: notmuch_database_t): cstring {.importc: "notmuch_database_status_string", header: "notmuch.h".}
## *
##  Commit changes and close the given notmuch database.
##
##  After notmuch_database_close has been called, calls to other
##  functions on objects derived from this database may either behave
##  as if the database had not been closed (e.g., if the required data
##  has been cached) or may fail with a
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION. The only further operation
##  permitted on the database itself is to call
##  notmuch_database_destroy.
##
##  notmuch_database_close can be called multiple times.  Later calls
##  have no effect.
##
##  For writable databases, notmuch_database_close commits all changes
##  to disk before closing the database.  If the caller is currently in
##  an atomic section (there was a notmuch_database_begin_atomic
##  without a matching notmuch_database_end_atomic), this will discard
##  changes made in that atomic section (but still commit changes made
##  prior to entering the atomic section).
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully closed the database.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred; the
## 	database has been closed but there are no guarantees the
## 	changes to the database, if any, have been flushed to disk.
##

proc close*(database: notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_close", header: "notmuch.h".}
## *
##  A callback invoked by notmuch_database_compact to notify the user
##  of the progress of the compaction process.
##

type
  notmuch_compact_status_cb_t* = proc (message: cstring; closure: pointer)

## *
##  Compact a notmuch database, backing up the original database to the
##  given path.
##
##  The database will be opened with NOTMUCH_DATABASE_MODE_READ_WRITE
##  during the compaction process to ensure no writes are made.
##
##  If the optional callback function 'status_cb' is non-NULL, it will
##  be called with diagnostic and informational messages. The argument
##  'closure' is passed verbatim to any callback invoked.
##

proc compact*(path: cstring; backup_path: cstring; status_cb: notmuch_compact_status_cb_t; closure: pointer): notmuch_status_t {.importc: "notmuch_database_compact", header: "notmuch.h".}
## *
##  Destroy the notmuch database, closing it if necessary and freeing
##  all associated resources.
##
##  Return value as in notmuch_database_close if the database was open;
##  notmuch_database_destroy itself has no failure modes.
##

proc destroy*(database: notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_destroy", header: "notmuch.h".}
## *
##  Return the database path of the given database.
##
##  The return value is a string owned by notmuch so should not be
##  modified nor freed by the caller.
##

proc get_path*(database: notmuch_database_t): cstring {.importc: "notmuch_database_get_path", header: "notmuch.h".}
## *
##  Return the database format version of the given database.
##

proc get_version*(database: notmuch_database_t): cuint {.importc: "notmuch_database_get_version", header: "notmuch.h".}
## *
##  Can the database be upgraded to a newer database version?
##
##  If this function returns TRUE, then the caller may call
##  notmuch_database_upgrade to upgrade the database.  If the caller
##  does not upgrade an out-of-date database, then some functions may
##  fail with NOTMUCH_STATUS_UPGRADE_REQUIRED.  This always returns
##  FALSE for a read-only database because there's no way to upgrade a
##  read-only database.
##

proc needs_upgrade*(database: notmuch_database_t): notmuch_bool_t {.importc: "notmuch_database_needs_upgrade", header: "notmuch.h".}
## *
##  Upgrade the current database to the latest supported version.
##
##  This ensures that all current notmuch functionality will be
##  available on the database.  After opening a database in read-write
##  mode, it is recommended that clients check if an upgrade is needed
##  (notmuch_database_needs_upgrade) and if so, upgrade with this
##  function before making any modifications.  If
##  notmuch_database_needs_upgrade returns FALSE, this will be a no-op.
##
##  The optional progress_notify callback can be used by the caller to
##  provide progress indication to the user. If non-NULL it will be
##  called periodically with 'progress' as a floating-point value in
##  the range of [0.0 .. 1.0] indicating the progress made so far in
##  the upgrade process.  The argument 'closure' is passed verbatim to
##  any callback invoked.
##

proc upgrade*(database: notmuch_database_t; progress_notify: proc (closure: pointer; progress: cdouble); closure: pointer): notmuch_status_t {.importc: "notmuch_database_upgrade", header: "notmuch.h".}
## *
##  Begin an atomic database operation.
##
##  Any modifications performed between a successful begin and a
##  notmuch_database_end_atomic will be applied to the database
##  atomically.  Note that, unlike a typical database transaction, this
##  only ensures atomicity, not durability; neither begin nor end
##  necessarily flush modifications to disk.
##
##  Atomic sections may be nested.  begin_atomic and end_atomic must
##  always be called in pairs.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully entered atomic section.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred;
## 	atomic section not entered.
##

proc begin_atomic*(notmuch: notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_begin_atomic", header: "notmuch.h".}
## *
##  Indicate the end of an atomic database operation.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully completed atomic section.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred;
## 	atomic section not ended.
##
##  NOTMUCH_STATUS_UNBALANCED_ATOMIC: The database is not currently in
## 	an atomic section.
##

proc end_atomic*(notmuch: notmuch_database_t): notmuch_status_t {.importc: "notmuch_database_end_atomic", header: "notmuch.h".}
## *
##  Return the committed database revision and UUID.
##
##  The database revision number increases monotonically with each
##  commit to the database.  Hence, all messages and message changes
##  committed to the database (that is, visible to readers) have a last
##  modification revision <= the committed database revision.  Any
##  messages committed in the future will be assigned a modification
##  revision > the committed database revision.
##
##  The UUID is a NUL-terminated opaque string that uniquely identifies
##  this database.  Two revision numbers are only comparable if they
##  have the same database UUID.
##

proc get_revision*(notmuch: notmuch_database_t; uuid: ptr cstring): culong {.importc: "notmuch_database_get_revision", header: "notmuch.h".}
## *
##  Retrieve a directory object from the database for 'path'.
##
##  Here, 'path' should be a path relative to the path of 'database'
##  (see notmuch_database_get_path), or else should be an absolute path
##  with initial components that match the path of 'database'.
##
##  If this directory object does not exist in the database, this
##  returns NOTMUCH_STATUS_SUCCESS and sets *directory to NULL.
##
##  Otherwise the returned directory object is owned by the database
##  and as such, will only be valid until notmuch_database_destroy is
##  called.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successfully retrieved directory.
##
##  NOTMUCH_STATUS_NULL_POINTER: The given 'directory' argument is NULL.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred;
## 	directory not retrieved.
##
##  NOTMUCH_STATUS_UPGRADE_REQUIRED: The caller must upgrade the
##  	database to use this function.
##

proc get_directory*(database: notmuch_database_t; path: cstring; directory: ptr notmuch_directory_t): notmuch_status_t {.importc: "notmuch_database_get_directory", header: "notmuch.h".}
## *
##  Add a message file to a database, indexing it for retrieval by
##  future searches.  If a message already exists with the same message
##  ID as the specified file, their indexes will be merged, and this
##  new filename will also be associated with the existing message.
##
##  Here, 'filename' should be a path relative to the path of
##  'database' (see notmuch_database_get_path), or else should be an
##  absolute filename with initial components that match the path of
##  'database'.
##
##  The file should be a single mail message (not a multi-message mbox)
##  that is expected to remain at its current location, (since the
##  notmuch database will reference the filename, and will not copy the
##  entire contents of the file.
##
##  If another message with the same message ID already exists in the
##  database, rather than creating a new message, this adds the search
##  terms from the identified file to the existing message's index, and
##  adds 'filename' to the list of filenames known for the message.
##
##  The 'indexopts' parameter can be NULL (meaning, use the indexing
##  defaults from the database), or can be an explicit choice of
##  indexing options that should govern the indexing of this specific
##  'filename'.
##
##  If 'message' is not NULL, then, on successful return
##  (NOTMUCH_STATUS_SUCCESS or NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID) '*message'
##  will be initialized to a message object that can be used for things
##  such as adding tags to the just-added message. The user should call
##  notmuch_message_destroy when done with the message. On any failure
##  '*message' will be set to NULL.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Message successfully added to database.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred,
## 	message not added.
##
##  NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID: Message has the same message
## 	ID as another message already in the database. The new
## 	filename was successfully added to the message in the database
## 	(if not already present) and the existing message is returned.
##
##  NOTMUCH_STATUS_FILE_ERROR: an error occurred trying to open the
## 	file, (such as permission denied, or file not found,
## 	etc.). Nothing added to the database.
##
##  NOTMUCH_STATUS_FILE_NOT_EMAIL: the contents of filename don't look
## 	like an email message. Nothing added to the database.
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so no message can be added.
##
##  NOTMUCH_STATUS_UPGRADE_REQUIRED: The caller must upgrade the
##  	database to use this function.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc index_file*(database: notmuch_database_t; filename: cstring; indexopts: notmuch_indexopts_t; message: ptr notmuch_message_t): notmuch_status_t {.importc: "notmuch_database_index_file", header: "notmuch.h".}
## *
##  Remove a message filename from the given notmuch database. If the
##  message has no more filenames, remove the message.
##
##  If the same message (as determined by the message ID) is still
##  available via other filenames, then the message will persist in the
##  database for those filenames. When the last filename is removed for
##  a particular message, the database content for that message will be
##  entirely removed.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: The last filename was removed and the
## 	message was removed from the database.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred,
## 	message not removed.
##
##  NOTMUCH_STATUS_DUPLICATE_MESSAGE_ID: This filename was removed but
## 	the message persists in the database with at least one other
## 	filename.
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so no message can be removed.
##
##  NOTMUCH_STATUS_UPGRADE_REQUIRED: The caller must upgrade the
##  	database to use this function.
##

proc remove_message*(database: notmuch_database_t; filename: cstring): notmuch_status_t {.importc: "notmuch_database_remove_message", header: "notmuch.h".}
## *
##  Find a message with the given message_id.
##
##  If a message with the given message_id is found then, on successful return
##  (NOTMUCH_STATUS_SUCCESS) '*message' will be initialized to a message
##  object.  The caller should call notmuch_message_destroy when done with the
##  message.
##
##  On any failure or when the message is not found, this function initializes
##  '*message' to NULL. This means, when NOTMUCH_STATUS_SUCCESS is returned, the
##  caller is supposed to check '*message' for NULL to find out whether the
##  message with the given message_id was found.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successful return, check '*message'.
##
##  NOTMUCH_STATUS_NULL_POINTER: The given 'message' argument is NULL
##
##  NOTMUCH_STATUS_OUT_OF_MEMORY: Out of memory, creating message object
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred
##

proc find_message*(database: notmuch_database_t; message_id: cstring; message: ptr  notmuch_message_t): notmuch_status_t {.importc: "notmuch_database_find_message", header: "notmuch.h".}
## *
##  Find a message with the given filename.
##
##  If the database contains a message with the given filename then, on
##  successful return (NOTMUCH_STATUS_SUCCESS) '*message' will be initialized to
##  a message object. The caller should call notmuch_message_destroy when done
##  with the message.
##
##  On any failure or when the message is not found, this function initializes
##  '*message' to NULL. This means, when NOTMUCH_STATUS_SUCCESS is returned, the
##  caller is supposed to check '*message' for NULL to find out whether the
##  message with the given filename is found.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Successful return, check '*message'
##
##  NOTMUCH_STATUS_NULL_POINTER: The given 'message' argument is NULL
##
##  NOTMUCH_STATUS_OUT_OF_MEMORY: Out of memory, creating the message object
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception occurred
##
##  NOTMUCH_STATUS_UPGRADE_REQUIRED: The caller must upgrade the
##  	database to use this function.
##

proc find_message_by_filename*(notmuch: notmuch_database_t; filename: cstring; message: ptr  notmuch_message_t): notmuch_status_t {.importc: "notmuch_database_find_message_by_filename", header: "notmuch.h".}
## *
##  Return a list of all tags found in the database.
##
##  This function creates a list of all tags found in the database. The
##  resulting list contains all tags from all messages found in the database.
##
##  On error this function returns NULL.
##

proc get_all_tags*(db: notmuch_database_t): notmuch_tags_t {.importc: "notmuch_database_get_all_tags", header: "notmuch.h".}
## *
##  Create a new query for 'database'.
##
##  Here, 'database' should be an open database, (see
##  notmuch_database_open and notmuch_database_create).
##
##  For the query string, we'll document the syntax here more
##  completely in the future, but it's likely to be a specialized
##  version of the general Xapian query syntax:
##
##  https://xapian.org/docs/queryparser.html
##
##  As a special case, passing either a length-zero string, (that is ""),
##  or a string consisting of a single asterisk (that is "*"), will
##  result in a query that returns all messages in the database.
##
##  See notmuch_query_set_sort for controlling the order of results.
##  See notmuch_query_search_messages and notmuch_query_search_threads
##  to actually execute the query.
##
##  User should call notmuch_query_destroy when finished with this
##  query.
##
##  Will return NULL if insufficient memory is available.
##

proc create*(database: notmuch_database_t; query_string: cstring): notmuch_query_t {.importc: "notmuch_query_create", header: "notmuch.h".}
## *
##  Sort values for notmuch_query_set_sort.
##

type
  notmuch_sort_t* {.size: sizeof(cint).} = enum
    NOTMUCH_SORT_OLDEST_FIRST,  ## *
                                ##  Oldest first.
                                ##

    NOTMUCH_SORT_NEWEST_FIRST,  ## *
                                ##  Newest first.
                                ##

    NOTMUCH_SORT_MESSAGE_ID,    ## *
                                ##  Sort by message-id.
                                ##

    NOTMUCH_SORT_UNSORTED       ## *
                                ##  Do not sort.
                                ##


## *
##  Return the query_string of this query. See notmuch_query_create.
##

proc get_query_string*(query: notmuch_query_t): cstring {.importc: "notmuch_query_get_query_string", header: "notmuch.h".}
## *
##  Return the notmuch database of this query. See notmuch_query_create.
##

proc get_database*(query: notmuch_query_t): notmuch_database_t {.importc: "notmuch_query_get_database", header: "notmuch.h".}
## *
##  Exclude values for notmuch_query_set_omit_excluded. The strange
##  order is to maintain backward compatibility: the old FALSE/TRUE
##  options correspond to the new
##  NOTMUCH_EXCLUDE_FLAG/NOTMUCH_EXCLUDE_TRUE options.
##

type
  notmuch_exclude_t* {.size: sizeof(cint).} = enum
    NOTMUCH_EXCLUDE_FLAG,
    NOTMUCH_EXCLUDE_TRUE,
    NOTMUCH_EXCLUDE_FALSE,
    NOTMUCH_EXCLUDE_ALL


## *
##  Specify whether to omit excluded results or simply flag them.  By
##  default, this is set to TRUE.
##
##  If set to TRUE or ALL, notmuch_query_search_messages will omit excluded
##  messages from the results, and notmuch_query_search_threads will omit
##  threads that match only in excluded messages.  If set to TRUE,
##  notmuch_query_search_threads will include all messages in threads that
##  match in at least one non-excluded message.  Otherwise, if set to ALL,
##  notmuch_query_search_threads will omit excluded messages from all threads.
##
##  If set to FALSE or FLAG then both notmuch_query_search_messages and
##  notmuch_query_search_threads will return all matching
##  messages/threads regardless of exclude status. If set to FLAG then
##  the exclude flag will be set for any excluded message that is
##  returned by notmuch_query_search_messages, and the thread counts
##  for threads returned by notmuch_query_search_threads will be the
##  number of non-excluded messages/matches. Otherwise, if set to
##  FALSE, then the exclude status is completely ignored.
##
##  The performance difference when calling
##  notmuch_query_search_messages should be relatively small (and both
##  should be very fast).  However, in some cases,
##  notmuch_query_search_threads is very much faster when omitting
##  excluded messages as it does not need to construct the threads that
##  only match in excluded messages.
##

proc set_omit_excluded*(query: notmuch_query_t; omit_excluded: notmuch_exclude_t) {.importc: "notmuch_query_set_omit_excluded", header: "notmuch.h".}
## *
##  Specify the sorting desired for this query.
##

proc set_sort*(query: notmuch_query_t; sort: notmuch_sort_t) {.importc: "notmuch_query_set_sort", header: "notmuch.h".}
## *
##  Return the sort specified for this query. See
##  notmuch_query_set_sort.
##

proc query_get_sort*(query: ptr notmuch_query_t): notmuch_sort_t {.importc: "notmuch_query_get_sort", header: "notmuch.h".}
## *
##  Add a tag that will be excluded from the query results by default.
##  This exclusion will be ignored if this tag appears explicitly in
##  the query.
##
##  @returns
##
##  NOTMUCH_STATUS_SUCCESS: excluded was added successfully.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: a Xapian exception occurred.
##       Most likely a problem lazily parsing the query string.
##
##  NOTMUCH_STATUS_IGNORED: tag is explicitly present in the query, so
## 		not excluded.
##

proc add_tag_exclude*(query: notmuch_query_t; tag: cstring): notmuch_status_t {.importc: "notmuch_query_add_tag_exclude", header: "notmuch.h".}
## *
##  Execute a query for threads, returning a notmuch_threads_t object
##  which can be used to iterate over the results. The returned threads
##  object is owned by the query and as such, will only be valid until
##  notmuch_query_destroy.
##
##  Typical usage might be:
##
##      notmuch_query_t *query;
##      notmuch_threads_t *threads;
##      notmuch_thread_t *thread;
##
##      query = notmuch_query_create (database, query_string);
##
##      for (threads = notmuch_query_search_threads (query);
##           notmuch_threads_valid (threads);
##           notmuch_threads_move_to_next (threads))
##      {
##          thread = notmuch_threads_get (threads);
##          ....
##          notmuch_thread_destroy (thread);
##      }
##
##      notmuch_query_destroy (query);
##
##  Note: If you are finished with a thread before its containing
##  query, you can call notmuch_thread_destroy to clean up some memory
##  sooner (as in the above example). Otherwise, if your thread objects
##  are long-lived, then you don't need to call notmuch_thread_destroy
##  and all the memory will still be reclaimed when the query is
##  destroyed.
##
##  Note that there's no explicit destructor needed for the
##  notmuch_threads_t object. (For consistency, we do provide a
##  notmuch_threads_destroy function, but there's no good reason
##  to call it if the query is about to be destroyed).
##
##  @since libnotmuch 5.0 (notmuch 0.25)
##

proc search_threads*(query: notmuch_query_t; `out`: ptr notmuch_threads_t): notmuch_status_t {.importc: "notmuch_query_search_threads", header: "notmuch.h".}
## *
##  Execute a query for messages, returning a notmuch_messages_t object
##  which can be used to iterate over the results. The returned
##  messages object is owned by the query and as such, will only be
##  valid until notmuch_query_destroy.
##
##  Typical usage might be:
##
##      notmuch_query_t *query;
##      notmuch_messages_t *messages;
##      notmuch_message_t *message;
##
##      query = notmuch_query_create (database, query_string);
##
##      for (messages = notmuch_query_search_messages (query);
##           notmuch_messages_valid (messages);
##           notmuch_messages_move_to_next (messages))
##      {
##          message = notmuch_messages_get (messages);
##          ....
##          notmuch_message_destroy (message);
##      }
##
##      notmuch_query_destroy (query);
##
##  Note: If you are finished with a message before its containing
##  query, you can call notmuch_message_destroy to clean up some memory
##  sooner (as in the above example). Otherwise, if your message
##  objects are long-lived, then you don't need to call
##  notmuch_message_destroy and all the memory will still be reclaimed
##  when the query is destroyed.
##
##  Note that there's no explicit destructor needed for the
##  notmuch_messages_t object. (For consistency, we do provide a
##  notmuch_messages_destroy function, but there's no good
##  reason to call it if the query is about to be destroyed).
##
##  If a Xapian exception occurs this function will return NULL.
##
##  @since libnotmuch 5 (notmuch 0.25)
##

proc search_messages*(query: notmuch_query_t; `out`: ptr notmuch_messages_t): notmuch_status_t {.importc: "notmuch_query_search_messages", header: "notmuch.h".}
## *
##  Destroy a notmuch_query_t along with any associated resources.
##
##  This will in turn destroy any notmuch_threads_t and
##  notmuch_messages_t objects generated by this query, (and in
##  turn any notmuch_thread_t and notmuch_message_t objects generated
##  from those results, etc.), if such objects haven't already been
##  destroyed.
##

proc destroy*(query: notmuch_query_t) {.importc: "notmuch_query_destroy", header: "notmuch.h".}
## *
##  Is the given 'threads' iterator pointing at a valid thread.
##
##  When this function returns TRUE, notmuch_threads_get will return a
##  valid object. Whereas when this function returns FALSE,
##  notmuch_threads_get will return NULL.
##
##  If passed a NULL pointer, this function returns FALSE
##
##  See the documentation of notmuch_query_search_threads for example
##  code showing how to iterate over a notmuch_threads_t object.
##

proc valid*(threads: notmuch_threads_t): notmuch_bool_t {.importc: "notmuch_threads_valid", header: "notmuch.h".}
## *
##  Get the current thread from 'threads' as a notmuch_thread_t.
##
##  Note: The returned thread belongs to 'threads' and has a lifetime
##  identical to it (and the query to which it belongs).
##
##  See the documentation of notmuch_query_search_threads for example
##  code showing how to iterate over a notmuch_threads_t object.
##
##  If an out-of-memory situation occurs, this function will return
##  NULL.
##

proc get*(threads: notmuch_threads_t): notmuch_thread_t {.importc: "notmuch_threads_get", header: "notmuch.h".}
## *
##  Move the 'threads' iterator to the next thread.
##
##  If 'threads' is already pointing at the last thread then the
##  iterator will be moved to a point just beyond that last thread,
##  (where notmuch_threads_valid will return FALSE and
##  notmuch_threads_get will return NULL).
##
##  See the documentation of notmuch_query_search_threads for example
##  code showing how to iterate over a notmuch_threads_t object.
##

proc move_to_next*(threads: notmuch_threads_t) {.importc: "notmuch_threads_move_to_next", header: "notmuch.h".}

iterator items*(iter: notmuch_threads_t): notmuch_thread_t =
  while iter.valid() == 1:
    yield iter.get()
    iter.move_to_next()

## *
##  Destroy a notmuch_threads_t object.
##
##  It's not strictly necessary to call this function. All memory from
##  the notmuch_threads_t object will be reclaimed when the
##  containing query object is destroyed.
##

proc destroy*(threads: notmuch_threads_t) {.importc: "notmuch_threads_destroy", header: "notmuch.h".}
## *
##  Return the number of messages matching a search.
##
##  This function performs a search and returns the number of matching
##  messages.
##
##  @returns
##
##  NOTMUCH_STATUS_SUCCESS: query completed successfully.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: a Xapian exception occurred. The
##       value of *count is not defined.
##
##  @since libnotmuch 5 (notmuch 0.25)
##

proc count_messages*(query: notmuch_query_t; count: ptr cuint): notmuch_status_t {.importc: "notmuch_query_count_messages", header: "notmuch.h".}
## *
##  Return the number of threads matching a search.
##
##  This function performs a search and returns the number of unique thread IDs
##  in the matching messages. This is the same as number of threads matching a
##  search.
##
##  Note that this is a significantly heavier operation than
##  notmuch_query_count_messages{_st}().
##
##  @returns
##
##  NOTMUCH_STATUS_OUT_OF_MEMORY: Memory allocation failed. The value
##       of *count is not defined
##
##  NOTMUCH_STATUS_SUCCESS: query completed successfully.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: a Xapian exception occurred. The
##       value of *count is not defined.
##
##  @since libnotmuch 5 (notmuch 0.25)
##

proc count_threads*(query: notmuch_query_t; count: ptr cuint): notmuch_status_t {.importc: "notmuch_query_count_threads", header: "notmuch.h".}
## *
##  Get the thread ID of 'thread'.
##
##  The returned string belongs to 'thread' and as such, should not be
##  modified by the caller and will only be valid for as long as the
##  thread is valid, (which is until notmuch_thread_destroy or until
##  the query from which it derived is destroyed).
##

proc get_thread_id*(thread: notmuch_thread_t): cstring {.importc: "notmuch_thread_get_thread_id", header: "notmuch.h".}
## *
##  Get the total number of messages in 'thread'.
##
##  This count consists of all messages in the database belonging to
##  this thread. Contrast with notmuch_thread_get_matched_messages() .
##

proc thread_get_total_messages*(thread: notmuch_thread_t): cint {.importc: "notmuch_thread_get_total_messages", header: "notmuch.h".}
## *
##  Get the total number of files in 'thread'.
##
##  This sums notmuch_message_count_files over all messages in the
##  thread
##  @returns Non-negative integer
##  @since libnotmuch 5.0 (notmuch 0.25)
##

proc get_total_files*(thread: notmuch_thread_t): cint {.importc: "notmuch_thread_get_total_files", header: "notmuch.h".}
## *
##  Get a notmuch_messages_t iterator for the top-level messages in
##  'thread' in oldest-first order.
##
##  This iterator will not necessarily iterate over all of the messages
##  in the thread. It will only iterate over the messages in the thread
##  which are not replies to other messages in the thread.
##
##  The returned list will be destroyed when the thread is destroyed.
##

proc get_toplevel_messages*(thread: notmuch_thread_t): notmuch_messages_t {.importc: "notmuch_thread_get_toplevel_messages", header: "notmuch.h".}
## *
##  Get a notmuch_thread_t iterator for all messages in 'thread' in
##  oldest-first order.
##
##  The returned list will be destroyed when the thread is destroyed.
##

proc get_messages*(thread: notmuch_thread_t): notmuch_messages_t {.importc: "notmuch_thread_get_messages", header: "notmuch.h".}
## *
##  Get the number of messages in 'thread' that matched the search.
##
##  This count includes only the messages in this thread that were
##  matched by the search from which the thread was created and were
##  not excluded by any exclude tags passed in with the query (see
##  notmuch_query_add_tag_exclude). Contrast with
##  notmuch_thread_get_total_messages() .
##

proc get_matched_messages*(thread: notmuch_thread_t): cint {.importc: "notmuch_thread_get_matched_messages", header: "notmuch.h".}
## *
##  Get the authors of 'thread' as a UTF-8 string.
##
##  The returned string is a comma-separated list of the names of the
##  authors of mail messages in the query results that belong to this
##  thread.
##
##  The string contains authors of messages matching the query first, then
##  non-matched authors (with the two groups separated by '|'). Within
##  each group, authors are ordered by date.
##
##  The returned string belongs to 'thread' and as such, should not be
##  modified by the caller and will only be valid for as long as the
##  thread is valid, (which is until notmuch_thread_destroy or until
##  the query from which it derived is destroyed).
##

proc get_authors*(thread: notmuch_thread_t): cstring {.importc: "notmuch_thread_get_authors", header: "notmuch.h".}
## *
##  Get the subject of 'thread' as a UTF-8 string.
##
##  The subject is taken from the first message (according to the query
##  order---see notmuch_query_set_sort) in the query results that
##  belongs to this thread.
##
##  The returned string belongs to 'thread' and as such, should not be
##  modified by the caller and will only be valid for as long as the
##  thread is valid, (which is until notmuch_thread_destroy or until
##  the query from which it derived is destroyed).
##

proc get_subject*(thread: notmuch_thread_t): cstring {.importc: "notmuch_thread_get_subject", header: "notmuch.h".}
## *
##  Get the date of the oldest message in 'thread' as a time_t value.
##

proc get_oldest_date*(thread: notmuch_thread_t): time_t {.importc: "notmuch_thread_get_oldest_date", header: "notmuch.h".}
## *
##  Get the date of the newest message in 'thread' as a time_t value.
##

proc get_newest_date*(thread: ptr notmuch_thread_t): time_t {.importc: "notmuch_thread_get_newest_date", header: "notmuch.h".}
## *
##  Get the tags for 'thread', returning a notmuch_tags_t object which
##  can be used to iterate over all tags.
##
##  Note: In the Notmuch database, tags are stored on individual
##  messages, not on threads. So the tags returned here will be all
##  tags of the messages which matched the search and which belong to
##  this thread.
##
##  The tags object is owned by the thread and as such, will only be
##  valid for as long as the thread is valid, (for example, until
##  notmuch_thread_destroy or until the query from which it derived is
##  destroyed).
##
##  Typical usage might be:
##
##      notmuch_thread_t *thread;
##      notmuch_tags_t *tags;
##      const char *tag;
##
##      thread = notmuch_threads_get (threads);
##
##      for (tags = notmuch_thread_get_tags (thread);
##           notmuch_tags_valid (tags);
##           notmuch_tags_move_to_next (tags))
##      {
##          tag = notmuch_tags_get (tags);
##          ....
##      }
##
##      notmuch_thread_destroy (thread);
##
##  Note that there's no explicit destructor needed for the
##  notmuch_tags_t object. (For consistency, we do provide a
##  notmuch_tags_destroy function, but there's no good reason to call
##  it if the message is about to be destroyed).
##

proc get_tags*(thread: notmuch_thread_t): notmuch_tags_t {.importc: "notmuch_thread_get_tags", header: "notmuch.h".}
## *
##  Destroy a notmuch_thread_t object.
##

proc destroy*(thread: notmuch_thread_t) {.importc: "notmuch_thread_destroy", header: "notmuch.h".}
## *
##  Is the given 'messages' iterator pointing at a valid message.
##
##  When this function returns TRUE, notmuch_messages_get will return a
##  valid object. Whereas when this function returns FALSE,
##  notmuch_messages_get will return NULL.
##
##  See the documentation of notmuch_query_search_messages for example
##  code showing how to iterate over a notmuch_messages_t object.
##

proc valid*(messages: notmuch_messages_t): notmuch_bool_t {.importc: "notmuch_messages_valid", header: "notmuch.h".}
## *
##  Get the current message from 'messages' as a notmuch_message_t.
##
##  Note: The returned message belongs to 'messages' and has a lifetime
##  identical to it (and the query to which it belongs).
##
##  See the documentation of notmuch_query_search_messages for example
##  code showing how to iterate over a notmuch_messages_t object.
##
##  If an out-of-memory situation occurs, this function will return
##  NULL.
##

proc get*(messages: notmuch_messages_t): notmuch_message_t {.importc: "notmuch_messages_get", header: "notmuch.h".}
## *
##  Move the 'messages' iterator to the next message.
##
##  If 'messages' is already pointing at the last message then the
##  iterator will be moved to a point just beyond that last message,
##  (where notmuch_messages_valid will return FALSE and
##  notmuch_messages_get will return NULL).
##
##  See the documentation of notmuch_query_search_messages for example
##  code showing how to iterate over a notmuch_messages_t object.
##

proc move_to_next*(messages: notmuch_messages_t) {.importc: "notmuch_messages_move_to_next", header: "notmuch.h".}

iterator items*(iter: notmuch_messages_t): notmuch_message_t =
  while iter.valid() == 1:
    yield iter.get()
    iter.move_to_next()

## *
##  Destroy a notmuch_messages_t object.
##
##  It's not strictly necessary to call this function. All memory from
##  the notmuch_messages_t object will be reclaimed when the containing
##  query object is destroyed.
##

proc destroy*(messages: notmuch_messages_t) {.importc: "notmuch_messages_destroy", header: "notmuch.h".}
## *
##  Return a list of tags from all messages.
##
##  The resulting list is guaranteed not to contain duplicated tags.
##
##  WARNING: You can no longer iterate over messages after calling this
##  function, because the iterator will point at the end of the list.
##  We do not have a function to reset the iterator yet and the only
##  way how you can iterate over the list again is to recreate the
##  message list.
##
##  The function returns NULL on error.
##

proc collect_tags*(messages: notmuch_messages_t): notmuch_tags_t {.importc: "notmuch_messages_collect_tags", header: "notmuch.h".}
## *
##  Get the database associated with this message.
##
##  @since libnotmuch 5.2 (notmuch 0.27)
##

proc get_database*(message: notmuch_message_t): notmuch_database_t {.importc: "notmuch_message_get_database", header: "notmuch.h".}
## *
##  Get the message ID of 'message'.
##
##  The returned string belongs to 'message' and as such, should not be
##  modified by the caller and will only be valid for as long as the
##  message is valid, (which is until the query from which it derived
##  is destroyed).
##
##  This function will not return NULL since Notmuch ensures that every
##  message has a unique message ID, (Notmuch will generate an ID for a
##  message if the original file does not contain one).
##

proc get_message_id*(message: notmuch_message_t): cstring {.importc: "notmuch_message_get_message_id", header: "notmuch.h".}
## *
##  Get the thread ID of 'message'.
##
##  The returned string belongs to 'message' and as such, should not be
##  modified by the caller and will only be valid for as long as the
##  message is valid, (for example, until the user calls
##  notmuch_message_destroy on 'message' or until a query from which it
##  derived is destroyed).
##
##  This function will not return NULL since Notmuch ensures that every
##  message belongs to a single thread.
##

proc get_thread_id*(message: notmuch_message_t): cstring {.importc: "notmuch_message_get_thread_id", header: "notmuch.h".}
## *
##  Get a notmuch_messages_t iterator for all of the replies to
##  'message'.
##
##  Note: This call only makes sense if 'message' was ultimately
##  obtained from a notmuch_thread_t object, (such as by coming
##  directly from the result of calling notmuch_thread_get_
##  toplevel_messages or by any number of subsequent
##  calls to notmuch_message_get_replies).
##
##  If 'message' was obtained through some non-thread means, (such as
##  by a call to notmuch_query_search_messages), then this function
##  will return NULL.
##
##  If there are no replies to 'message', this function will return
##  NULL. (Note that notmuch_messages_valid will accept that NULL
##  value as legitimate, and simply return FALSE for it.)
##

proc get_replies*(message: notmuch_message_t): notmuch_messages_t {.importc: "notmuch_message_get_replies", header: "notmuch.h".}
## *
##  Get the total number of files associated with a message.
##  @returns Non-negative integer
##  @since libnotmuch 5.0 (notmuch 0.25)
##

proc count_files*(message: notmuch_message_t): cint {.importc: "notmuch_message_count_files", header: "notmuch.h".}
## *
##  Get a filename for the email corresponding to 'message'.
##
##  The returned filename is an absolute filename, (the initial
##  component will match notmuch_database_get_path() ).
##
##  The returned string belongs to the message so should not be
##  modified or freed by the caller (nor should it be referenced after
##  the message is destroyed).
##
##  Note: If this message corresponds to multiple files in the mail
##  store, (that is, multiple files contain identical message IDs),
##  this function will arbitrarily return a single one of those
##  filenames. See notmuch_message_get_filenames for returning the
##  complete list of filenames.
##

proc get_filename*(message: notmuch_message_t): cstring {.importc: "notmuch_message_get_filename", header: "notmuch.h".}
## *
##  Get all filenames for the email corresponding to 'message'.
##
##  Returns a notmuch_filenames_t iterator listing all the filenames
##  associated with 'message'. These files may not have identical
##  content, but each will have the identical Message-ID.
##
##  Each filename in the iterator is an absolute filename, (the initial
##  component will match notmuch_database_get_path() ).
##

proc get_filenames*(message: notmuch_message_t): notmuch_filenames_t {.
    importc: "notmuch_message_get_filenames", header: "notmuch.h".}
## *
##  Re-index the e-mail corresponding to 'message' using the supplied index options
##
##  Returns the status of the re-index operation.  (see the return
##  codes documented in notmuch_database_index_file)
##
##  After reindexing, the user should discard the message object passed
##  in here by calling notmuch_message_destroy, since it refers to the
##  original message, not to the reindexed message.
##

proc reindex*(message: notmuch_message_t; indexopts: notmuch_indexopts_t): notmuch_status_t {.importc: "notmuch_message_reindex", header: "notmuch.h".}
## *
##  Message flags.
##

type
  notmuch_message_flag_t* {.size: sizeof(cint).} = enum
    NOTMUCH_MESSAGE_FLAG_MATCH,
    NOTMUCH_MESSAGE_FLAG_EXCLUDED,
    NOTMUCH_MESSAGE_FLAG_GHOST      ##  This message is a "ghost message", meaning it has no filenames
                                    ##  or content, but we know it exists because it was referenced by
                                    ##  some other message.  A ghost message has only a message ID and
                                    ##  thread ID.
                                    ##


## *
##  Get a value of a flag for the email corresponding to 'message'.
##

proc get_flag*(message: notmuch_message_t; flag: notmuch_message_flag_t): notmuch_bool_t {.importc: "notmuch_message_get_flag", header: "notmuch.h".}
## *
##  Set a value of a flag for the email corresponding to 'message'.
##

proc set_flag*(message: notmuch_message_t; flag: notmuch_message_flag_t; value: notmuch_bool_t) {.importc: "notmuch_message_set_flag", header: "notmuch.h".}
## *
##  Get the date of 'message' as a time_t value.
##
##  For the original textual representation of the Date header from the
##  message call notmuch_message_get_header() with a header value of
##  "date".
##

proc get_date*(message: notmuch_message_t): time_t {.importc: "notmuch_message_get_date", header: "notmuch.h".}
## *
##  Get the value of the specified header from 'message' as a UTF-8 string.
##
##  Common headers are stored in the database when the message is
##  indexed and will be returned from the database.  Other headers will
##  be read from the actual message file.
##
##  The header name is case insensitive.
##
##  The returned string belongs to the message so should not be
##  modified or freed by the caller (nor should it be referenced after
##  the message is destroyed).
##
##  Returns an empty string ("") if the message does not contain a
##  header line matching 'header'. Returns NULL if any error occurs.
##

proc get_header*(message: notmuch_message_t; header: cstring): cstring {.importc: "notmuch_message_get_header", header: "notmuch.h".}
## *
##  Get the tags for 'message', returning a notmuch_tags_t object which
##  can be used to iterate over all tags.
##
##  The tags object is owned by the message and as such, will only be
##  valid for as long as the message is valid, (which is until the
##  query from which it derived is destroyed).
##
##  Typical usage might be:
##
##      notmuch_message_t *message;
##      notmuch_tags_t *tags;
##      const char *tag;
##
##      message = notmuch_database_find_message (database, message_id);
##
##      for (tags = notmuch_message_get_tags (message);
##           notmuch_tags_valid (tags);
##           notmuch_tags_move_to_next (tags))
##      {
##          tag = notmuch_tags_get (tags);
##          ....
##      }
##
##      notmuch_message_destroy (message);
##
##  Note that there's no explicit destructor needed for the
##  notmuch_tags_t object. (For consistency, we do provide a
##  notmuch_tags_destroy function, but there's no good reason to call
##  it if the message is about to be destroyed).
##

proc get_tags*(message: notmuch_message_t): notmuch_tags_t {.importc: "notmuch_message_get_tags", header: "notmuch.h".}
## *
##  The longest possible tag value.
##

const
  NOTMUCH_TAG_MAX* = 200

## *
##  Add a tag to the given message.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Tag successfully added to message
##
##  NOTMUCH_STATUS_NULL_POINTER: The 'tag' argument is NULL
##
##  NOTMUCH_STATUS_TAG_TOO_LONG: The length of 'tag' is too long
## 	(exceeds NOTMUCH_TAG_MAX)
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so message cannot be modified.
##

proc add_tag*(message: notmuch_message_t; tag: cstring): notmuch_status_t {.importc: "notmuch_message_add_tag", header: "notmuch.h".}
## *
##  Remove a tag from the given message.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Tag successfully removed from message
##
##  NOTMUCH_STATUS_NULL_POINTER: The 'tag' argument is NULL
##
##  NOTMUCH_STATUS_TAG_TOO_LONG: The length of 'tag' is too long
## 	(exceeds NOTMUCH_TAG_MAX)
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so message cannot be modified.
##

proc remove_tag*(message: notmuch_message_t; tag: cstring): notmuch_status_t {.importc: "notmuch_message_remove_tag", header: "notmuch.h".}
## *
##  Remove all tags from the given message.
##
##  See notmuch_message_freeze for an example showing how to safely
##  replace tag values.
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so message cannot be modified.
##

proc remove_all_tags*(message: notmuch_message_t): notmuch_status_t {.importc: "notmuch_message_remove_all_tags", header: "notmuch.h".}
## *
##  Add/remove tags according to maildir flags in the message filename(s).
##
##  This function examines the filenames of 'message' for maildir
##  flags, and adds or removes tags on 'message' as follows when these
##  flags are present:
##
## 	Flag	Action if present
## 	----	-----------------
## 	'D'	Adds the "draft" tag to the message
## 	'F'	Adds the "flagged" tag to the message
## 	'P'	Adds the "passed" tag to the message
## 	'R'	Adds the "replied" tag to the message
## 	'S'	Removes the "unread" tag from the message
##
##  For each flag that is not present, the opposite action (add/remove)
##  is performed for the corresponding tags.
##
##  Flags are identified as trailing components of the filename after a
##  sequence of ":2,".
##
##  If there are multiple filenames associated with this message, the
##  flag is considered present if it appears in one or more
##  filenames. (That is, the flags from the multiple filenames are
##  combined with the logical OR operator.)
##
##  A client can ensure that notmuch database tags remain synchronized
##  with maildir flags by calling this function after each call to
##  notmuch_database_index_file. See also
##  notmuch_message_tags_to_maildir_flags for synchronizing tag changes
##  back to maildir flags.
##

proc maildir_flags_to_tags*(message: notmuch_message_t): notmuch_status_t {.importc: "notmuch_message_maildir_flags_to_tags", header: "notmuch.h".}
## *
##  return TRUE if any filename of 'message' has maildir flag 'flag',
##  FALSE otherwise.
##
##

proc has_maildir_flag*(message: notmuch_message_t; flag: char): notmuch_bool_t {.importc: "notmuch_message_has_maildir_flag", header: "notmuch.h".}
## *
##  Rename message filename(s) to encode tags as maildir flags.
##
##  Specifically, for each filename corresponding to this message:
##
##  If the filename is not in a maildir directory, do nothing.  (A
##  maildir directory is determined as a directory named "new" or
##  "cur".) Similarly, if the filename has invalid maildir info,
##  (repeated or outof-ASCII-order flag characters after ":2,"), then
##  do nothing.
##
##  If the filename is in a maildir directory, rename the file so that
##  its filename ends with the sequence ":2," followed by zero or more
##  of the following single-character flags (in ASCII order):
##
##    * flag 'D' iff the message has the "draft" tag
##    * flag 'F' iff the message has the "flagged" tag
##    * flag 'P' iff the message has the "passed" tag
##    * flag 'R' iff the message has the "replied" tag
##    * flag 'S' iff the message does not have the "unread" tag
##
##  Any existing flags unmentioned in the list above will be preserved
##  in the renaming.
##
##  Also, if this filename is in a directory named "new", rename it to
##  be within the neighboring directory named "cur".
##
##  A client can ensure that maildir filename flags remain synchronized
##  with notmuch database tags by calling this function after changing
##  tags, (after calls to notmuch_message_add_tag,
##  notmuch_message_remove_tag, or notmuch_message_freeze/
##  notmuch_message_thaw). See also notmuch_message_maildir_flags_to_tags
##  for synchronizing maildir flag changes back to tags.
##

proc tags_to_maildir_flags*(message: notmuch_message_t): notmuch_status_t {.importc: "notmuch_message_tags_to_maildir_flags", header: "notmuch.h".}
## *
##  Freeze the current state of 'message' within the database.
##
##  This means that changes to the message state, (via
##  notmuch_message_add_tag, notmuch_message_remove_tag, and
##  notmuch_message_remove_all_tags), will not be committed to the
##  database until the message is thawed with notmuch_message_thaw.
##
##  Multiple calls to freeze/thaw are valid and these calls will
##  "stack". That is there must be as many calls to thaw as to freeze
##  before a message is actually thawed.
##
##  The ability to do freeze/thaw allows for safe transactions to
##  change tag values. For example, explicitly setting a message to
##  have a given set of tags might look like this:
##
##     notmuch_message_freeze (message);
##
##     notmuch_message_remove_all_tags (message);
##
##     for (i = 0; i < NUM_TAGS; i++)
##         notmuch_message_add_tag (message, tags[i]);
##
##     notmuch_message_thaw (message);
##
##  With freeze/thaw used like this, the message in the database is
##  guaranteed to have either the full set of original tag values, or
##  the full set of new tag values, but nothing in between.
##
##  Imagine the example above without freeze/thaw and the operation
##  somehow getting interrupted. This could result in the message being
##  left with no tags if the interruption happened after
##  notmuch_message_remove_all_tags but before notmuch_message_add_tag.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Message successfully frozen.
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so message cannot be modified.
##

proc freeze*(message: notmuch_message_t): notmuch_status_t {.importc: "notmuch_message_freeze", header: "notmuch.h".}
## *
##  Thaw the current 'message', synchronizing any changes that may have
##  occurred while 'message' was frozen into the notmuch database.
##
##  See notmuch_message_freeze for an example of how to use this
##  function to safely provide tag changes.
##
##  Multiple calls to freeze/thaw are valid and these calls with
##  "stack". That is there must be as many calls to thaw as to freeze
##  before a message is actually thawed.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: Message successfully thawed, (or at least
## 	its frozen count has successfully been reduced by 1).
##
##  NOTMUCH_STATUS_UNBALANCED_FREEZE_THAW: An attempt was made to thaw
## 	an unfrozen message. That is, there have been an unbalanced
## 	number of calls to notmuch_message_freeze and
## 	notmuch_message_thaw.
##

proc thaw*(message: notmuch_message_t): notmuch_status_t {.importc: "notmuch_message_thaw", header: "notmuch.h".}
## *
##  Destroy a notmuch_message_t object.
##
##  It can be useful to call this function in the case of a single
##  query object with many messages in the result, (such as iterating
##  over the entire database). Otherwise, it's fine to never call this
##  function and there will still be no memory leaks. (The memory from
##  the messages get reclaimed when the containing query is destroyed.)
##

proc message_destroy*(message: notmuch_message_t) {.importc: "notmuch_message_destroy", header: "notmuch.h".}
## *
##  @name Message Properties
##
##  This interface provides the ability to attach arbitrary (key,value)
##  string pairs to a message, to remove such pairs, and to iterate
##  over them.  The caller should take some care as to what keys they
##  add or delete values for, as other subsystems or extensions may
##  depend on these properties.
##
##  Please see notmuch-properties(7) for more details about specific
##  properties and conventions around their use.
##
##
## *@{
## *
##  Retrieve the value for a single property key
##
##  *value* is set to a string owned by the message or NULL if there is
##  no such key. In the case of multiple values for the given key, the
##  first one is retrieved.
##
##  @returns
##  - NOTMUCH_STATUS_NULL_POINTER: *value* may not be NULL.
##  - NOTMUCH_STATUS_SUCCESS: No error occurred.
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc get_property*(message: notmuch_message_t; key: cstring; value: ptr cstring): notmuch_status_t {.importc: "notmuch_message_get_property", header: "notmuch.h".}
## *
##  Add a (key,value) pair to a message
##
##  @returns
##  - NOTMUCH_STATUS_ILLEGAL_ARGUMENT: *key* may not contain an '=' character.
##  - NOTMUCH_STATUS_NULL_POINTER: Neither *key* nor *value* may be NULL.
##  - NOTMUCH_STATUS_SUCCESS: No error occurred.
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc add_property*(message: notmuch_message_t; key: cstring; value: cstring): notmuch_status_t {.importc: "notmuch_message_add_property", header: "notmuch.h".}
## *
##  Remove a (key,value) pair from a message.
##
##  It is not an error to remove a non-existant (key,value) pair
##
##  @returns
##  - NOTMUCH_STATUS_ILLEGAL_ARGUMENT: *key* may not contain an '=' character.
##  - NOTMUCH_STATUS_NULL_POINTER: Neither *key* nor *value* may be NULL.
##  - NOTMUCH_STATUS_SUCCESS: No error occurred.
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc remove_property*(message: notmuch_message_t; key: cstring; value: cstring): notmuch_status_t {.importc: "notmuch_message_remove_property", header: "notmuch.h".}
## *
##  Remove all (key,value) pairs from the given message.
##
##  @param[in,out] message  message to operate on.
##  @param[in]     key      key to delete properties for. If NULL, delete
## 			   properties for all keys
##  @returns
##  - NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in
##    read-only mode so message cannot be modified.
##  - NOTMUCH_STATUS_SUCCESS: No error occurred.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc remove_all_properties*(message: notmuch_message_t; key: cstring): notmuch_status_t {.importc: "notmuch_message_remove_all_properties", header: "notmuch.h".}
## *
##  Remove all (prefix*,value) pairs from the given message
##
##  @param[in,out] message  message to operate on.
##  @param[in]     prefix   delete properties with keys that start with prefix.
## 			   If NULL, delete all properties
##  @returns
##  - NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in
##    read-only mode so message cannot be modified.
##  - NOTMUCH_STATUS_SUCCESS: No error occurred.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc remove_all_properties_with_prefix*(message: notmuch_message_t; prefix: cstring): notmuch_status_t {.importc: "notmuch_message_remove_all_properties_with_prefix", header: "notmuch.h".}
## *
##  Opaque message property iterator
##

type
  notmuch_message_properties_t* = distinct ptr object

## *
##  Get the properties for *message*, returning a
##  notmuch_message_properties_t object which can be used to iterate
##  over all properties.
##
##  The notmuch_message_properties_t object is owned by the message and
##  as such, will only be valid for as long as the message is valid,
##  (which is until the query from which it derived is destroyed).
##
##  @param[in] message  The message to examine
##  @param[in] key      key or key prefix
##  @param[in] exact    if TRUE, require exact match with key. Otherwise
## 		       treat as prefix.
##
##  Typical usage might be:
##
##      notmuch_message_properties_t *list;
##
##      for (list = notmuch_message_get_properties (message, "testkey1", TRUE);
##           notmuch_message_properties_valid (list); notmuch_message_properties_move_to_next (list)) {
##         printf("%s\n", notmuch_message_properties_value(list));
##      }
##
##      notmuch_message_properties_destroy (list);
##
##  Note that there's no explicit destructor needed for the
##  notmuch_message_properties_t object. (For consistency, we do
##  provide a notmuch_message_properities_destroy function, but there's
##  no good reason to call it if the message is about to be destroyed).
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc get_properties*(message: notmuch_message_t; key: cstring; exact: notmuch_bool_t): notmuch_message_properties_t {.importc: "notmuch_message_get_properties", header: "notmuch.h".}
## *
##  Return the number of properties named "key" belonging to the specific message.
##
##  @param[in] message  The message to examine
##  @param[in] key      key to count
##  @param[out] count   The number of matching properties associated with this message.
##
##  @returns
##
##  NOTMUCH_STATUS_SUCCESS: successful count, possibly some other error.
##
##  @since libnotmuch 5.2 (notmuch 0.27)
##

proc count_properties*(message: notmuch_message_t; key: cstring; count: ptr cuint): notmuch_status_t {.importc: "notmuch_message_count_properties", header: "notmuch.h".}
## *
##  Is the given *properties* iterator pointing at a valid (key,value)
##  pair.
##
##  When this function returns TRUE,
##  notmuch_message_properties_{key,value} will return a valid string,
##  and notmuch_message_properties_move_to_next will do what it
##  says. Whereas when this function returns FALSE, calling any of
##  these functions results in undefined behaviour.
##
##  See the documentation of notmuch_message_get_properties for example
##  code showing how to iterate over a notmuch_message_properties_t
##  object.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc valid*(properties: notmuch_message_properties_t): notmuch_bool_t {.importc: "notmuch_message_properties_valid", header: "notmuch.h".}
## *
##  Move the *properties* iterator to the next (key,value) pair
##
##  If *properties* is already pointing at the last pair then the iterator
##  will be moved to a point just beyond that last pair, (where
##  notmuch_message_properties_valid will return FALSE).
##
##  See the documentation of notmuch_message_get_properties for example
##  code showing how to iterate over a notmuch_message_properties_t object.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc move_to_next*(properties: notmuch_message_properties_t) {.importc: "notmuch_message_properties_move_to_next", header: "notmuch.h".}
## *
##  Return the key from the current (key,value) pair.
##
##  this could be useful if iterating for a prefix
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc key*(properties: notmuch_message_properties_t): cstring {.importc: "notmuch_message_properties_key", header: "notmuch.h".}

iterator keys*(iter: notmuch_message_properties_t): cstring =
  while iter.valid() == 1:
    yield iter.key()
    iter.move_to_next()

## *
##  Return the value from the current (key,value) pair.
##
##  This could be useful if iterating for a prefix.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc value*(properties: notmuch_message_properties_t): cstring {.importc: "notmuch_message_properties_value", header: "notmuch.h".}

iterator values*(iter: notmuch_message_properties_t): cstring =
  while iter.valid() == 1:
    yield iter.value()
    iter.move_to_next()

iterator pairs*(iter: notmuch_message_properties_t): (cstring, cstring) =
  while iter.valid() == 1:
    yield (iter.key(), iter.value())
    iter.move_to_next()

## *
##  Destroy a notmuch_message_properties_t object.
##
##  It's not strictly necessary to call this function. All memory from
##  the notmuch_message_properties_t object will be reclaimed when the
##  containing message object is destroyed.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc destroy*(properties: notmuch_message_properties_t) {.importc: "notmuch_message_properties_destroy", header: "notmuch.h".}
## *@}
## *
##  Is the given 'tags' iterator pointing at a valid tag.
##
##  When this function returns TRUE, notmuch_tags_get will return a
##  valid string. Whereas when this function returns FALSE,
##  notmuch_tags_get will return NULL.
##
##  See the documentation of notmuch_message_get_tags for example code
##  showing how to iterate over a notmuch_tags_t object.
##

proc valid*(tags: notmuch_tags_t): notmuch_bool_t {.importc: "notmuch_tags_valid", header: "notmuch.h".}
## *
##  Get the current tag from 'tags' as a string.
##
##  Note: The returned string belongs to 'tags' and has a lifetime
##  identical to it (and the query to which it ultimately belongs).
##
##  See the documentation of notmuch_message_get_tags for example code
##  showing how to iterate over a notmuch_tags_t object.
##

proc get*(tags: notmuch_tags_t): cstring {.importc: "notmuch_tags_get", header: "notmuch.h".}
## *
##  Move the 'tags' iterator to the next tag.
##
##  If 'tags' is already pointing at the last tag then the iterator
##  will be moved to a point just beyond that last tag, (where
##  notmuch_tags_valid will return FALSE and notmuch_tags_get will
##  return NULL).
##
##  See the documentation of notmuch_message_get_tags for example code
##  showing how to iterate over a notmuch_tags_t object.
##

proc move_to_next*(tags: notmuch_tags_t) {.importc: "notmuch_tags_move_to_next", header: "notmuch.h".}

iterator items*(iter: notmuch_tags_t): cstring =
  while iter.valid() == 1:
    yield iter.get()
    iter.move_to_next()

## *
##  Destroy a notmuch_tags_t object.
##
##  It's not strictly necessary to call this function. All memory from
##  the notmuch_tags_t object will be reclaimed when the containing
##  message or query objects are destroyed.
##

proc destroy*(tags: notmuch_tags_t) {.importc: "notmuch_tags_destroy", header: "notmuch.h".}
## *
##  Store an mtime within the database for 'directory'.
##
##  The 'directory' should be an object retrieved from the database
##  with notmuch_database_get_directory for a particular path.
##
##  The intention is for the caller to use the mtime to allow efficient
##  identification of new messages to be added to the database. The
##  recommended usage is as follows:
##
##    o Read the mtime of a directory from the filesystem
##
##    o Call index_file for all mail files in the directory
##
##    o Call notmuch_directory_set_mtime with the mtime read from the
##      filesystem.
##
##  Then, when wanting to check for updates to the directory in the
##  future, the client can call notmuch_directory_get_mtime and know
##  that it only needs to add files if the mtime of the directory and
##  files are newer than the stored timestamp.
##
##  Note: The notmuch_directory_get_mtime function does not allow the
##  caller to distinguish a timestamp of 0 from a non-existent
##  timestamp. So don't store a timestamp of 0 unless you are
##  comfortable with that.
##
##  Return value:
##
##  NOTMUCH_STATUS_SUCCESS: mtime successfully stored in database.
##
##  NOTMUCH_STATUS_XAPIAN_EXCEPTION: A Xapian exception
## 	occurred, mtime not stored.
##
##  NOTMUCH_STATUS_READ_ONLY_DATABASE: Database was opened in read-only
## 	mode so directory mtime cannot be modified.
##

proc set_mtime*(directory: notmuch_directory_t; mtime: time_t): notmuch_status_t {.importc: "notmuch_directory_set_mtime", header: "notmuch.h".}
## *
##  Get the mtime of a directory, (as previously stored with
##  notmuch_directory_set_mtime).
##
##  Returns 0 if no mtime has previously been stored for this
##  directory.
##

proc get_mtime*(directory: notmuch_directory_t): time_t {.importc: "notmuch_directory_get_mtime", header: "notmuch.h".}
## *
##  Get a notmuch_filenames_t iterator listing all the filenames of
##  messages in the database within the given directory.
##
##  The returned filenames will be the basename-entries only (not
##  complete paths).
##

proc directory_get_child_files*(directory: notmuch_directory_t): notmuch_filenames_t {.importc: "notmuch_directory_get_child_files", header: "notmuch.h".}
## *
##  Get a notmuch_filenames_t iterator listing all the filenames of
##  sub-directories in the database within the given directory.
##
##  The returned filenames will be the basename-entries only (not
##  complete paths).
##

proc get_child_directories*(directory: notmuch_directory_t): notmuch_filenames_t {.importc: "notmuch_directory_get_child_directories", header: "notmuch.h".}
## *
##  Delete directory document from the database, and destroy the
##  notmuch_directory_t object. Assumes any child directories and files
##  have been deleted by the caller.
##
##  @since libnotmuch 4.3 (notmuch 0.21)
##

proc delete*(directory: notmuch_directory_t): notmuch_status_t {.importc: "notmuch_directory_delete", header: "notmuch.h".}
## *
##  Destroy a notmuch_directory_t object.
##

proc destroy*(directory: notmuch_directory_t) {.importc: "notmuch_directory_destroy", header: "notmuch.h".}
## *
##  Is the given 'filenames' iterator pointing at a valid filename.
##
##  When this function returns TRUE, notmuch_filenames_get will return
##  a valid string. Whereas when this function returns FALSE,
##  notmuch_filenames_get will return NULL.
##
##  It is acceptable to pass NULL for 'filenames', in which case this
##  function will always return FALSE.
##

proc valid*(filenames: notmuch_filenames_t): notmuch_bool_t {.importc: "notmuch_filenames_valid", header: "notmuch.h".}
## *
##  Get the current filename from 'filenames' as a string.
##
##  Note: The returned string belongs to 'filenames' and has a lifetime
##  identical to it (and the directory to which it ultimately belongs).
##
##  It is acceptable to pass NULL for 'filenames', in which case this
##  function will always return NULL.
##

proc get*(filenames: notmuch_filenames_t): cstring {.importc: "notmuch_filenames_get", header: "notmuch.h".}
## *
##  Move the 'filenames' iterator to the next filename.
##
##  If 'filenames' is already pointing at the last filename then the
##  iterator will be moved to a point just beyond that last filename,
##  (where notmuch_filenames_valid will return FALSE and
##  notmuch_filenames_get will return NULL).
##
##  It is acceptable to pass NULL for 'filenames', in which case this
##  function will do nothing.
##

proc move_to_next*(filenames: notmuch_filenames_t) {.importc: "notmuch_filenames_move_to_next", header: "notmuch.h".}

iterator items*(iter: notmuch_filenames_t): cstring =
  while iter.valid() == 1:
    yield iter.get()
    iter.move_to_next()

## *
##  Destroy a notmuch_filenames_t object.
##
##  It's not strictly necessary to call this function. All memory from
##  the notmuch_filenames_t object will be reclaimed when the
##  containing directory object is destroyed.
##
##  It is acceptable to pass NULL for 'filenames', in which case this
##  function will do nothing.
##

proc destroy*(filenames: notmuch_filenames_t) {.importc: "notmuch_filenames_destroy", header: "notmuch.h".}
## *
##  set config 'key' to 'value'
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc set_config*(db: notmuch_database_t; key: cstring; value: cstring): notmuch_status_t {.importc: "notmuch_database_set_config", header: "notmuch.h".}
## *
##  retrieve config item 'key', assign to  'value'
##
##  keys which have not been previously set with n_d_set_config will
##  return an empty string.
##
##  return value is allocated by malloc and should be freed by the
##  caller.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc get_config*(db: notmuch_database_t; key: cstring; value: ptr cstring): notmuch_status_t {.importc: "notmuch_database_get_config", header: "notmuch.h".}
## *
##  Create an iterator for all config items with keys matching a given prefix
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc get_config_list*(db: notmuch_database_t; prefix: cstring; `out`: ptr notmuch_config_list_t): notmuch_status_t {.importc: "notmuch_database_get_config_list", header: "notmuch.h".}
## *
##  Is 'config_list' iterator valid (i.e. _key, _value, _move_to_next can be called).
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc valid*(config_list: notmuch_config_list_t): notmuch_bool_t {.importc: "notmuch_config_list_valid", header: "notmuch.h".}
## *
##  return key for current config pair
##
##  return value is owned by the iterator, and will be destroyed by the
##  next call to notmuch_config_list_key or notmuch_config_list_destroy.
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc key*(config_list: notmuch_config_list_t): cstring {.importc: "notmuch_config_list_key", header: "notmuch.h".}
## *
##  return 'value' for current config pair
##
##  return value is owned by the iterator, and will be destroyed by the
##  next call to notmuch_config_list_value or notmuch config_list_destroy
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc value*(config_list: notmuch_config_list_t): cstring {.importc: "notmuch_config_list_value", header: "notmuch.h".}
## *
##  move 'config_list' iterator to the next pair
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc move_to_next*(config_list: notmuch_config_list_t) {.importc: "notmuch_config_list_move_to_next", header: "notmuch.h".}

iterator pairs*(iter: notmuch_config_list_t): (cstring, cstring) =
  while iter.valid() == 1:
    yield (iter.key(), iter.value())
    iter.move_to_next()

iterator keys*(iter: notmuch_config_list_t): cstring =
  while iter.valid() == 1:
    yield iter.key()
    iter.move_to_next()

iterator values*(iter: notmuch_config_list_t): cstring =
  while iter.valid() == 1:
    yield iter.value()
    iter.move_to_next()

## *
##  free any resources held by 'config_list'
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc destroy*(config_list: notmuch_config_list_t) {.importc: "notmuch_config_list_destroy", header: "notmuch.h".}
## *
##  get the current default indexing options for a given database.
##
##  This object will survive until the database itself is destroyed,
##  but the caller may also release it earlier with
##  notmuch_indexopts_destroy.
##
##  This object represents a set of options on how a message can be
##  added to the index.  At the moment it is a featureless stub.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc get_default_indexopts*(db: notmuch_database_t): notmuch_indexopts_t {.importc: "notmuch_database_get_default_indexopts", header: "notmuch.h".}
## *
##  Stating a policy about how to decrypt messages.
##
##  See index.decrypt in notmuch-config(1) for more details.
##

type
  notmuch_decryption_policy_t* {.size: sizeof(cint).} = enum
    NOTMUCH_DECRYPT_FALSE,
    NOTMUCH_DECRYPT_TRUE,
    NOTMUCH_DECRYPT_AUTO,
    NOTMUCH_DECRYPT_NOSTASH

## *
##  Specify whether to decrypt encrypted parts while indexing.
##
##  Be aware that the index is likely sufficient to reconstruct the
##  cleartext of the message itself, so please ensure that the notmuch
##  message index is adequately protected. DO NOT SET THIS FLAG TO TRUE
##  without considering the security of your index.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc set_decrypt_policy*(indexopts: notmuch_indexopts_t; decrypt_policy: notmuch_decryption_policy_t): notmuch_status_t {.importc: "notmuch_indexopts_set_decrypt_policy", header: "notmuch.h".}
## *
##  Return whether to decrypt encrypted parts while indexing.
##  see notmuch_indexopts_set_decrypt_policy.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc get_decrypt_policy*(indexopts: notmuch_indexopts_t): notmuch_decryption_policy_t {.importc: "notmuch_indexopts_get_decrypt_policy", header: "notmuch.h".}
## *
##  Destroy a notmuch_indexopts_t object.
##
##  @since libnotmuch 5.1 (notmuch 0.26)
##

proc destroy*(options: notmuch_indexopts_t) {.importc: "notmuch_indexopts_destroy", header: "notmuch.h".}
## *
##  interrogate the library for compile time features
##
##  @since libnotmuch 4.4 (notmuch 0.23)
##

proc built_with*(name: cstring): notmuch_bool_t {.importc: "notmuch_built_with", header: "notmuch.h".}

##  @}
