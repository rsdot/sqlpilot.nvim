import re


def get_filecontent(filepath):
    """Returns DDL content of `filepath` passed"""
    f = open(filepath, "r")
    content = f.read()
    f.close()
    return content


def regex_replace_common(formated):
    # concat lines
    regex = re.compile('\n(\S)', re.S)
    formated = regex.sub(r'\1', formated)
    # remove STORGAE block
    regex = re.compile('\n\s*STORAGE\(.*?\)', re.S)
    formated = regex.sub('', formated)
    # remove LOB STORE AS block
    regex = re.compile('\n\s*LOB \("\w+"\) STORE AS \w+ ("\w+")?\(.*?\)', re.S)
    formated = regex.sub('', formated)
    # remove TABLESPACE block
    regex = re.compile('\n\s*TABLESPACE [^\n]+', re.S)
    formated = regex.sub('', formated)
    # remove PCTFREE line
    regex = re.compile('\n\s*PCTFREE [^\n]+', re.S)
    formated = regex.sub('', formated)
    # concat PARALLEL line
    regex = re.compile('\n\s*PARALLEL', re.S)
    formated = regex.sub(' PARALLEL', formated)
    # remove PARALLEL
    regex = re.compile('\s*PARALLEL \d+', re.S)
    formated = regex.sub('', formated)
    return formated


def regex_replace_common_index(formated):
    formated = regex_replace_common(formated)
    # remove system generated index name
    regex = re.compile('UNIQUE INDEX "\w+"\."SYS_C00\w+"', re.S)
    formated = regex.sub(' UNIQUE INDEX', formated)
    return formated


def regex_replace_common_trigger(formated):
    # separate trigger body
    regex = re.compile('(.*?\nBEGIN)(.*)(\nEND;.*)', re.S)
    formatedheader = regex.sub(r'\1', formated)
    formatedbody = regex.sub(r'\2', formated)
    formatedfooter = regex.sub(r'\3', formated)
    # concat lines
    regex = re.compile('\n(\S)', re.S)
    formatedbody = regex.sub(r'\1', formatedbody)
    return f"{formatedheader}{formatedbody}{formatedfooter}"


def get_ddl_table(fc):
    """Extract table portion"""
    found = re.findall('CREATE TABLE.*?\n\n\n', fc, re.S)
    if found:
        formated = found[0]
        formated = regex_replace_common(formated)
        # remove SEGMENT CREATION IMMEDIATE|DEFERRED
        regex = re.compile(' SEGMENT CREATION (IMMEDIATE|DEFERRED)')
        formated = regex.sub('', formated)
        # remove USING INDEX line
        regex = re.compile('\n\s*USING INDEX [^\n]+', re.S)
        formated = regex.sub('', formated)
        # remove SUPPLEMENTAL LOG DATA line
        regex = re.compile('\n\s*SUPPLEMENTAL LOG DATA [^\n]+', re.S)
        formated = regex.sub('', formated)
        # remove NOCOMPRESS LOGGING line
        regex = re.compile('\n\s*NOCOMPRESS (NO)?LOGGING', re.S)
        formated = regex.sub('', formated)
        # remove Empty line
        regex = re.compile('\n\n', re.S)
        formated = regex.sub('\n', formated)
        # concat CASCASE line
        regex = re.compile('\n\s*CASCADE', re.S)
        formated = regex.sub(' CASCADE', formated)
        # concat REFERENCES line
        regex = re.compile('\n\s*REFERENCES', re.S)
        formated = regex.sub(' REFERENCES', formated)
        # format 1st field
        regex = re.compile('(\n\s*\()(\s*)', re.S)
        formated = regex.sub(r'\1\n\2', formated)
        # remove CACHE line
        regex = re.compile('\n\s*CACHE', re.S)
        formated = regex.sub('', formated)
        # remove PCTTHRESHOLD line
        regex = re.compile('\n\s*PCTTHRESHOLD [^\n]+', re.S)
        formated = regex.sub('', formated)
        # remove ORGANIZATION INDEX NOCOMPRESS PCTFREE line
        regex = re.compile('\s*ORGANIZATION INDEX NOCOMPRESS PCTFREE [^\n]+', re.S)
        formated = regex.sub('', formated)
        # remove last field's comma char
        regex = re.compile(',(\n\s*\))', re.S)
        formated = regex.sub(r'\1', formated)
        # change number(*,0) to number(38)
        regex = re.compile('NUMBER\(\*,0\)', re.S)
        formated = regex.sub('NUMBER(38)', formated)
        # change (xxx CHAR) to number(xxx)
        regex = re.compile('(\d+) CHAR\)', re.S)
        formated = regex.sub(r'\1)', formated)

        regex = re.compile('\n\n+', re.S)
        returnformated = regex.sub('\n', formated)
        return returnformated
    else:
        # print("table not found!")
        return ''


def get_ddl_indexes(fc):
    """Extract indexes portion"""
    returnformated = ''

    regex = re.compile('CREATE \w*\s*INDEX.*?\n\n\n', re.S)
    found = regex.findall(fc)
    if found:
        for formated in found:
            formated = regex_replace_common_index(formated)
            returnformated = f"{returnformated}{formated}"
    regex = re.compile('\n\n\n+', re.S)
    returnformated = regex.sub('\n', returnformated)
    return returnformated


def get_ddl_triggers(fc):
    """Extract triggers portion"""
    returnformated = ''

    regex = re.compile('CREATE OR REPLACE TRIGGER .*?\n\n\n', re.S)
    found = regex.findall(fc)
    if found:
        for formated in found:
            formated = regex_replace_common_trigger(formated)
            returnformated = f"{returnformated}{formated}"
    regex = re.compile('\n\n\n+', re.S)
    returnformated = regex.sub('\n', returnformated)
    return returnformated


def main(schema, filepath):
    fc = get_filecontent(filepath)
    # add newline at the end
    fc = f"{fc}\n"

    table = get_ddl_table(fc)
    indexes = get_ddl_indexes(fc)
    triggers = get_ddl_triggers(fc)

    regex = re.compile(f'"{schema}"\.')
    print(regex.sub('', table))
    print(regex.sub('', indexes))
    print(regex.sub('', triggers))


if __name__ == "__main__":
    import sys
    try:
        schema = sys.argv[1]
        filepath = sys.argv[2]
        main(schema, filepath)
    except IndexError:
        print("Please specify a file.\nUsage: python ddlscriptout.py [schema] [filepath]")
        exit(1)
