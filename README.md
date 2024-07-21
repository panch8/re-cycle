# Re-cycle

This is Re-Cycle, a project born in the #OIS24

Cycles are still an underappreciated asset. We all have significant reasons to test tools that assist us with their management tasks. It is worth mentioning that there are several fascinating projects currently underway that have inspired these ideas.

We believe in a stack-on-each-other's structure where we all contribute, ultimately benefiting a larger, shared space. However, it is essential to refine this concept, particularly in terms of feasibility and roadmap development.

## The Problem: 

Working with ICP blockchain involves deploying canisters, sometimes in large quantities. While this practice is generally beneficial for the ecosystem, it can occasionally lead to the creation of residual canisters. For instance, when developing an entire project in a test or development environment and then wanting to deploy a production version using new canisters, we may end up with residual canisters. This might be due to wanting canisters with a clean history or deciding to deploy everything on a specific subnet. Sometimes, we deploy canisters with ideas that are eventually forgotten. Other times, we create projects that programmatically generate canisters and simply lose track of them. When this happens, we generate residual smart contracts with no use or function.

In the Web2 world, if this occurs, the service provider (AWS, Azure, or your web hosting provider) will, after a certain period, ask if you want to keep your program running or charge you for keeping it online. In ICP, because resources are paid for in advance, when this happens, we end up "losing" cycles, meaning we lose computing power and storage—essentially, wasting money.

The idea behind Recycle is to create an open service, ideally as an online service with a downloadable library version(see section on ). It would be simple, the core of the kernel of a super dapp, akin to the trash bin on your computer. This would allow you to track all canisters subject to specific controllers, such as user identity, developer identity, cycles wallet, or custom canisters. Additionally, it would list all canisters under their control, providing information to evaluate their usage, and then proceed to the next step of "recycling" by destroying them and recovering the associated cycles. This way, you can reclaim all the lost and forgotten cycles you have.


### #OIS24 SCOPE

This repo provides a "manual" alpha version of the POC, with a copy-and-paste command solution for the terminal. The goal is to create a handy interface that will help gather community feedback. 



## Road-Map and next steps. 

## Mirrored Canister Administration Pattern
The immediate next step is to test a pattern to enable a frontend environment for the execution of third-party canister admin methods.

### Pattern Idea
As a developer, you have access to different identities such as DFX identities and Internet Identity, often using multiple identities to access controller admin methods. The idea is to use an Internet Identity to log in within a frontend, requiring just one command line interaction: granting the blackholed backend canister ID and the user-logged principal as new controllers of the wallet canister. After this, every interaction should occur in the frontend.

![docs/img/theScene1.png](fig. 1)


### Workflow

1. User Controls Two Identities: A developer identity and an Internet Identity. The developer identity controls multiple canisters (including the one to be deleted), while the Internet Identity provides a frontend experience.

2. User Logs in with Internet Identity: The user logs into the frontend using their Internet Identity.

3. Frontend Command Generation: The frontend returns a command to copy and paste into the CLI. This command executes an update-setting method, modifying a wallet canister's list of controllers by adding:

  - The logged-in user's principal, and
  - The service backend canister.

4. Backend Open Source Method: The open-source backend provides a `deleteMyCanisterMethod(canisterId, walletId)` triggered by the logged-in user. Since the backend is also a controller, it can instantiate the wallet canister and call a `deleteCanister(canisterId)` method on the wallet.

5. Backend Checks: Before instantiating the wallet, the backend verifies if the caller is a wallet controller, if it (the backend) is also a wallet controller, and if the wallet is the actual controller of the canister to be deleted.

6. Instantiating and Triggering Deletion: Once the checks are complete, the backend instantiates the wallet and triggers the deletion method.

7. Wallet Upgrade: The wallet should be upgraded to include a deleteCanister method to facilitate this process.