## Working memory delayed match to sample experimental paradigm

Our research aims to uncover mechanistic explanations of the neural basis of human behavior, that is, move from where to how. Our goals are multifaceted: (1) advance fundamental science by discovering new knowledge using rigorous, reproducible methods; and (2) advance translational applications in neurotechnology, precision medicine, and product development that are grounded in rigorous science. On each trial of this working memory task paradigm, participants encode three shapes in a specific spatiotemporal sequence in preparation for a self-paced match/mismatch recognition test of sequences that match exactly or mismatch on one dimension. It is intended for humans aged 13+ years with healthy cognitive function and normal/corrected-to-normal vision. It was designed for studies using intracranial and scalp EEG. 

It is described in:
- Cross, ZR, Gray, SM, Dede, AJO, Rivera, YM, Yin, Q, Vahidi, P, Rau, EMB, Cyr, C, Holubecki, AM, Asano, E, Lin, JJ, Kim McManus, O, Sattar, S, Saez, I, Girgis, F, King-Stephens, D, Weber, PB, Laxer, KD, Schuele, SU, Rosenow, JM, Wu, JY, Lam, SK, Raskin, JS, Chang, EF, Shaikhouni, A, Brunner, P, Roland, JL, Braga, RM, Knight, RT, Ofen, N, Johnson, EL. The development of aperiodic neural activity in the human brain. _Nature Human Behaviour_ (2025). [DOI](https://doi.org/10.1038/s41562-025-02270-x)
- Shi, L, Chattopadhyay, K, Gray, SM, Yarbrough, JB, King-Stephens, D, Saez, I, Girgis, F, Shaikhouni, A, Schuele, SU, Rosenow, JM, Asano, E, Knight, RT, Johnson, EL. Distributed theta networks support the control of working memory: Evidence from scalp and intracranial EEG. _bioRxiv_ (2025). [DOI](https://doi.org/10.1101/2025.08.14.670214)
- Yarbrough, JB, Shi, L, Chattopadhyay, K, Knight, RT, Johnson, EL. One of these things is not like the others: Theta, beta, and ERP dynamics of mismatch detection. _bioRxiv_ (2025). [DOI](https://doi.org/10.1101/2025.07.11.664390)

Publications and other papers using this paradigm should cite the publications above.

Software:
- MATLAB 8.6 (R2015b; last tested with R2021a)
- Psychtoolbox v.3.0.14 - [download](http://psychtoolbox.org/download)

Peripheral hardware:
- Mouse
- Photodiode sensor attached to the lower left of the screen

Output data are saved to a text file with one row per trial, as follows:
1. Trial number
2. Block number
3. Trial type (1-8: 1, 2 = match; 3, 4 = mismatch identity; 5, 6 = mismatch spatial; 7, 8 = mismatch temporal; 1, 3, 5, 7 include star; 2, 4, 6, 8 no star)
4. Response accuracy (0/1)
5. Response type (1-5; 1 = hit, 2 = miss, 3 = correct rejection, 4 = false alarm, 5 = unsure)
7. Response continuous distance
8. Response time (ms)
9. Star onset time relative to delay onset time (ms)
10. Inter-trial interval time
11. Stimulus swap spots (1, 2, 3)
12. Trial onset time (ms)
13. Response onset time (ms)

Output data are summarized by block in a separate text file.
