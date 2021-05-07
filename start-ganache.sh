#!/bin/bash
filename='.secret'
mnemonic=$(cat $filename)
npx ganache-cli -a 10 -m "$mnemonic"