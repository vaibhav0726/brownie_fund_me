from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
DECIMALS = 8
STARTING_PRICE = 200000000000
# this helps to check if it's in the development or it will be in ganache-local
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active netwok is {network.show_active()}")
    print(f"Deploying Mocks..")
    if len(MockV3Aggregator) <= 0:
        # or Web3.toWei(STARTING_PRICE, "ether") instead of STARTING_PRICE
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
    print("Mocks Deployed")
