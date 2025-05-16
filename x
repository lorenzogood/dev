#!/usr/bin/env bash

function switch() {
	home-manager switch --flake .#$1
}

if [[ -n $1 ]]; then 
	switch $1
else
        switch default	
fi
