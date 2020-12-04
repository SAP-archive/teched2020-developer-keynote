# Extract the VCAP_SERVICE JSON stanza from the output
# of a `cf env` invocation.

# Add a closing brace to the end of the stream.
$ a\
}

# Remove everything from the first closing brace
# (which will be of the VCAP_SERVICES structure),
# all the way to the end of the stream.
/^}$/,$d

# Print everything from an opening brace at the
# start of the line, to the end of the stream
/^{/,$p
