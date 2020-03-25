#!/bin/bash


toggle_leading_slash () {
    # First argument: File or directory path
    local _path=$1
    local _path_firstchar=${_path:0:1}

    # Second argument: Do you want the leading slash? [ 't' or 'f' ]
    # .sh likes leading slash .sql does not??
    local _return_lead_slash=$2
    local _return_lead_slash_firstchar=${_return_lead_slash:0:1}

    local _outpath=$_path

    if [ $_return_lead_slash_firstchar == 't' ] && [ $_path_firstchar != '/' ]; then
        _outpath="/${_path}"
    fi

    if [ $_return_lead_slash_firstchar == 'f' ] && [ $_path_firstchar == '/' ]; then
        _outpath="${_path:1}"
    fi

    NEW_PATH=$_outpath
}       

toggle_leading_slash '/home/' 't'
_keep=$NEW_PATH

toggle_leading_slash '/home/' 'f'
_remove=$NEW_PATH

toggle_leading_slash 'home/' 't'
_add=$NEW_PATH

toggle_leading_slash 'home/' 'f'
_dont_add=$NEW_PATH

echo $_keep
echo $_remove
echo $_add
echo $_dont_add
echo $_outpath