<img src="https://hardenad.net/wp-content/uploads/2021/12/Logo-HARDEN-AD-Horizontal-RVB@4x-300x86.png" align="center">

# Fork of HardenAD

This is a fork of the [HardenAD](https://github.com/LoicVeirman/HardenAD), which is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). This fork was created to add features and fix certain issues. All modifications are shared in compliance with the GPLv3 license requirements.

## Changes Made in This Fork

The following modifications were made:

1. Added translation of `sAMAccountName` and `UPN` during user creation.
2. Fixed the translation of the `TargetOU`.
3. Fixed the member name format in `HAD-LocalAdmins` GPOs for T2, T2L, and T1L environments.
4. Fixed the condition to check if the script has never run.

## Contributions Back to the Original Project

We aim to contribute back to the community by creating pull requests for fixes and features that might be valuable for the original project.

## License

This project is distributed under the [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html). See the `LICENSE` file for more details.

## Acknowledgments

Many thanks to the contributors of the [HardenAD](https://github.com/LoicVeirman/HardenAD) for their excellent work.